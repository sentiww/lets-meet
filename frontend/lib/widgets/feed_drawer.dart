import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class FeedDrawer extends StatefulWidget {
  const FeedDrawer({super.key});

  @override
  State<FeedDrawer> createState() => _FeedDrawerState();
}

class _FeedDrawerState extends State<FeedDrawer> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo aplikacji jako przycisk przenoszący do głównego feedu
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/feed');
                  },
                  child: Image.asset(
                    'assets/images/appLogoDark.png',
                    height: 40,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/likedEvents');
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Polubione wydarzenia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/completedEvents');
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Zakończone wydarzenia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/createEvent');
                },
                icon: const Icon(Icons.add),
                label: const Text('Dodaj wydarzenie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) context.go('/');
                  },
                  child: const Text(
                    'Wyloguj się',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Twoi znajomi'),
                onTap: () {
                  context.go('/friends');
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Zaproszenia do znajomych'),
                onTap: () {
                  context.go('/friendRequests');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Wyślij zaproszenie'),
                onTap: () {
                  context.go('/addFriend');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
