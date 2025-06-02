import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatFriendListScreen extends StatelessWidget {
  const ChatFriendListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Brak drawer i dolnego paska
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Strzałka powrotu do ekranu konwersacji
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.goNamed('chat_conversation');
          },
        ),
        // Logo aplikacji wyśrodkowane
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sekcja "Admini"
                  const Text(
                    'Admini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _FriendTile(
                    name: 'Ania',
                    avatarColor: Colors.pink,
                    onTap: () {
                      // Przejście do ekranu profilu innego użytkownika
                      // W GoRouterze powinna być trasa nazwana np. 'other_profile'
                      context.goNamed('other_profile');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sekcja "Uczestnicy"
                  const Text(
                    'Uczestnicy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Klikalny kafelek z uczestnikiem
                  _FriendTile(
                    name: 'Patryk',
                    avatarColor: Colors.purple,
                    onTap: () {
                      // Przejście do ekranu profilu innego użytkownika
                      context.goNamed('other_profile');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pojedynczy kafelek użytkownika (avatar + nazwa) według projektu.
/// Przycisk jest InkWellem, więc obsługuje onTap.
class _FriendTile extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final VoidCallback onTap;

  const _FriendTile({
    Key? key,
    required this.name,
    required this.avatarColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        // Białe tło i zaokrąglone rogi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Icon(Icons.person, color: avatarColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
