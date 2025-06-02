import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/feed_drawer.dart'; // <-- ten sam FeedDrawer co w FeedScreen

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Przykładowe statyczne dane (na później podmienisz na dane z backendu)
    final conversations = [
      'JEZZ',
      'JEZZ 2',
      'JEZZ 2',
      'JEZZ 2',
      'JEZZ 2',
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // --- AppBar z logo i przyciskiem otwierającym FeedDrawer
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

      // --- Używamy dokładnie tego samego FeedDrawer co w FeedScreen
      drawer: const FeedDrawer(),

      // --- Główna zawartość ekranu: lista konwersacji
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // (opcjonalnie możesz tutaj wstawić nagłówek, ale w przykładowym FeedScreen
                // nie było osobnego tekstu, tylko logo w AppBar)

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _ConversationTile(
                        title: conversations[index],
                        onTap: () {
                          // Po kliknięciu przechodzimy do ChatConversationScreen
                          context.goNamed('chat_conversation');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- Dolny pasek nawigacji
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Pozycja "Wiadomości"
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

/// Pojedynczy wiersz konwersacji – jasnoszara karta z napisem i strzałką
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
