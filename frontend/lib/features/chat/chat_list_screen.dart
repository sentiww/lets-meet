import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../../widgets/feed_drawer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Chat>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _chatsFuture = fetchChats();
  }

  Future<List<Chat>> fetchChats() async {
    final token = await AuthService.getAccessToken();
    if (token == null) {
      // Jeśli nie ma tokena, przekieruj na ekran logowania
      // lub wyrzuć wyjątek, który obsłużysz w FutureBuilderze.
      throw Exception('Unauthorized');
    }

    final uri = Uri.parse('http://localhost:8080/api/v1/chats');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final chatsJson = data['chats'] as List<dynamic>;
      return chatsJson
          .map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      // Token nieważny lub wygasł
      // Możesz odświeżyć token lub przekierować na logowanie
      final refreshed = await AuthService.refreshToken();
      if (refreshed) {
        return fetchChats(); // spróbuj ponownie po odświeżeniu
      } else {
        throw Exception('Unauthorized');
      }
    } else {
      throw Exception('Failed to load chats (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      drawer: const FeedDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: FutureBuilder<List<Chat>>(
                future: _chatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    if (error.contains('Unauthorized')) {
                      // Przekieruj na ekran logowania
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.goNamed('login');
                      });
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: Text(
                        'Błąd podczas ładowania czatów',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    );
                  } else {
                    final chats = snapshot.data!;
                    if (chats.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nie masz jeszcze żadnych konwersacji',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _ConversationTile(
                          title: chat.name,
                          onTap: () {
                            context.goNamed(
                              'chat_conversation',
                              pathParameters: {'chatId': chat.id.toString()},
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Odkrywaj',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Wiadomości',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('feed');
              break;
            case 1:
            // Jesteśmy już na liście wiadomości
              break;
            case 2:
              context.goNamed('profile');
              break;
          }
        },
      ),
    );
  }
}

/// Model pojedynczego czatu
class Chat {
  final int id;
  final int type;
  final String name;

  Chat({required this.id, required this.type, required this.name});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      type: json['type'] as int,
      name: json['name'] as String,
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ConversationTile({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
