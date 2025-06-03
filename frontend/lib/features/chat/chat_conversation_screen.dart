import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';

class ChatConversationScreen extends StatefulWidget {
  final int chatId;

  const ChatConversationScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late HubConnection _hubConnection;
  final List<ChatMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // 1) Pobierz początkowe wiadomości (REST)
      await _fetchInitialMessages();
      // 2) Potem uruchom SignalR
      await _setupSignalR();
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        // W razie braku tokena przejdź do logowania
        context.goNamed('login');
      } else {
        print('[ChatConversation] Initialization error: $e');
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchInitialMessages() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception('Unauthorized');

    final uri = Uri.parse('http://localhost:8080/api/v1/chats/${widget.chatId}');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final messagesJson = data['messages'] as List<dynamic>;
      setState(() {
        _messages.clear();
        _messages.addAll(messagesJson
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList());
      });
      _scrollToBottom();
      print('[ChatConversation] Załadowano ${_messages.length} wiadomości');
    } else if (response.statusCode == 401) {
      // Jeśli token wygasł, próbuj odświeżyć
      final refreshed = await AuthService.refreshToken();
      if (!refreshed) throw Exception('Unauthorized');
      await _fetchInitialMessages();
    } else {
      throw Exception('Failed to load messages (${response.statusCode})');
    }
  }

  Future<void> _setupSignalR() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception('Unauthorized');

    // *** WAŻNE: usuwamy ?chatId z URL-a ***
    final hubUrl = 'http://localhost:8080/hubs/v1/chat';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      HttpConnectionOptions(
        accessTokenFactory: () async => token,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection.onclose((error) {
      print('[SignalR] Connection closed: $error');
    });
    _hubConnection.onreconnecting((error) {
      print('[SignalR] Reconnecting: $error');
    });
    _hubConnection.onreconnected((id) {
      print('[SignalR] Reconnected: $id');
    });

    // Nasłuchujemy zdarzenia „NewMessage” (z ChatHub.UpdateAsync(...))
    _hubConnection.on('NewMessage', (arguments) async {
      print('[SignalR] Received NewMessage args: $arguments');
      if (arguments != null && arguments.length >= 2) {
        // Argumenty: [chatId, messageId]
        final rawChatId = arguments[0];
        final rawMsgId = arguments[1];
        final incomingChatId = (rawChatId is int)
            ? rawChatId
            : int.tryParse(rawChatId.toString());
        final incomingMsgId = (rawMsgId is int)
            ? rawMsgId
            : int.tryParse(rawMsgId.toString());

        if (incomingChatId == widget.chatId && incomingMsgId != null) {
          final newMsg = await _fetchSingleMessage(incomingMsgId);
          setState(() {
            _messages.add(newMsg);
          });
          _scrollToBottom();
          print('[ChatConversation] Dodano wiadomość ID $incomingMsgId');
        }
      }
    });

    print('[SignalR] Uruchamiam (WebSockets) połączenie do $hubUrl');
    await _hubConnection.start();
    print('[SignalR] Stan po połączeniu: ${_hubConnection.state}');
  }

  Future<ChatMessage> _fetchSingleMessage(int messageId) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception('Unauthorized');

    final uri = Uri.parse(
      'http://localhost:8080/api/v1/chats/${widget.chatId}/messages/$messageId',
    );
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('[ChatConversation] Pobrano pojedynczą wiadomość: $data');
      return ChatMessage.fromJson(data);
    } else if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshToken();
      if (!refreshed) throw Exception('Unauthorized');
      return _fetchSingleMessage(messageId);
    } else {
      throw Exception('Failed to load message ($messageId)');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final fromId = await AuthService.getCurrentUserId();
    if (fromId == null) {
      context.goNamed('login');
      return;
    }

    print('[ChatConversation] Wysyłam: "$content"');
    if (_hubConnection.state != HubConnectionState.connected) {
      print('[SignalR] Nie jest połączone, próbuję uruchomić ponownie...');
      try {
        await _hubConnection.start();
      } catch (e) {
        print('[SignalR] Błąd podczas ponownego łączenia: $e');
      }
      if (_hubConnection.state != HubConnectionState.connected) {
        print('[SignalR] Nadal nie połączono, przerywam wysłanie');
        return;
      }
    }

    try {
      // Tutaj wywołujemy metodę ChatHub.SendMessage(int chatId, int fromId, string content)
      await _hubConnection.invoke('SendMessage', args: [
        widget.chatId,
        fromId,
        content,
      ]);
      print('[SignalR] invoke SendMessage powiodło się');
      _messageController.clear();
    } catch (e) {
      print('[SignalR] BŁĄD przy SendMessage: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _hubConnection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.goNamed('chat_list');
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/appLogoDark.png',
              height: 40,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black54),
              onPressed: () {
                context.goNamed('chat_friend_list');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _messages.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nie ma jeszcze żadnych wiadomości',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Napisz jako pierwszy i rozpocznij rozmowę!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding:
                        const EdgeInsets.only(top: 16, bottom: 16),
                        itemCount: _messages.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _MessageCard(message: msg);
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Napisz wiadomość...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        shape: const CircleBorder(),
                        color: Colors.white,
                        elevation: 4,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _sendMessage,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.send,
                              color: Colors.black54,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final int id;
  final int fromId;
  final DateTime sentAt;
  final String content;

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.sentAt,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      fromId: json['fromId'] as int,
      sentAt: DateTime.parse(json['sentAt'] as String),
      content: json['content'] as String,
    );
  }
}

class _MessageCard extends StatelessWidget {
  final ChatMessage message;

  const _MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.black54, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${message.fromId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.sentAt.toLocal()}',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
