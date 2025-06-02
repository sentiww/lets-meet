import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({Key? key}) : super(key: key);

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Przykładowe, statyczne wiadomości (wydłużona lista dla testu scrollowania)
  final List<_ChatMessage> _messages = [
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz', 'Ale jezz', 'Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz'], avatarColor: Colors.pink),
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz', 'Ale jezz', 'Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz'], avatarColor: Colors.pink),
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz'], avatarColor: Colors.pink),
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz', 'Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz', 'Ale jezz'], avatarColor: Colors.pink),
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz', 'Ale jezz', 'Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz'], avatarColor: Colors.pink),
    _ChatMessage(sender: 'Patryk', textLines: ['Ale jezz'], avatarColor: Colors.purple),
    _ChatMessage(sender: 'Ania', textLines: ['Ale jezz'], avatarColor: Colors.pink),
  ];

  @override
  void initState() {
    super.initState();
    // Po zbudowaniu widoku przewiń na dół
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usunięto drawer i dolny pasek nawigacji
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Strzałka powrotu do listy czatów
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.goNamed('chat_list');
          },
        ),
        // Własny tytuł: logo + ikona ludzika bliżej środka
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/appLogoDark.png',
              height: 40,
            ),
            const SizedBox(width: 24), // Większa przerwa między logo a ikoną
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
            child: Column(
              children: [
                // Rozwijalna lista wiadomości
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        itemCount: _messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _MessageCard(message: msg);
                        },
                      ),
                    ),
                  ),
                ),

                // Pasek wpisywania wiadomości
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
                          onTap: () {
                            // Na razie brak logiki wysyłania
                            _messageController.clear();
                          },
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

/// Model jednej wiadomości (statyczne dane)
class _ChatMessage {
  final String sender;
  final List<String> textLines;
  final Color avatarColor;

  _ChatMessage({
    required this.sender,
    required this.textLines,
    required this.avatarColor,
  });
}

/// Widok "karty" pojedynczej wiadomości
class _MessageCard extends StatelessWidget {
  final _ChatMessage message;

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
            backgroundColor: message.avatarColor.withOpacity(0.2),
            child: Icon(Icons.person, color: message.avatarColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.sender,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                ...message.textLines.map(
                      (line) => Text(
                    line,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
