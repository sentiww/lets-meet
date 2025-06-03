import 'dart:convert'; // For handling UTF-8

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../services/blob_service.dart';
import '../../models/user.dart';
import '../../widgets/feed_drawer.dart'; // Added custom drawer

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Loads current user data
  Future<void> _loadProfile() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FeedDrawer(), // Navigation drawer
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
            ? const Center(child: Text('Błąd ładowania profilu'))
            : Center(
          // Center the content horizontally
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Center(
                    child: BlobService.buildProfileAvatar(
                      blobId: _user?.avatarId ?? 0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dodajemy nierzucające się w oczy ID użytkownika
                  if (_user?.id != null)
                    Text(
                      'Twoje ID: ${_user!.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 22),
                  _ProfileInfoTile(
                    label: 'Imię i nazwisko',
                    value: utf8.decode(
                      '${_user!.name} ${_user!.surname}'
                          .runes
                          .toList(),
                    ),
                    icon: Icons.person,
                  ),
                  _ProfileInfoTile(
                    label: 'Nazwa użytkownika',
                    value: '@${_user!.username}',
                    icon: Icons.alternate_email,
                  ),
                  _ProfileInfoTile(
                    label: 'E-mail',
                    value: _user!.email,
                    icon: Icons.mail_outline,
                  ),
                  _ProfileInfoTile(
                    label: 'Data urodzenia',
                    value: _user!.formattedDate,
                    icon: Icons.cake_outlined,
                  ),
                  const SizedBox(height: 80), // Spacer substitute
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final updated =
                        await context.push<bool>('/editProfile');
                        if (updated == true) {
                          _loadProfile(); // Refresh profile on return
                        }
                      },
                      label: const Text('Edytuj profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(currentIndex: 2),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E8F8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6A1B9A)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                      const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
        if (index == 0) context.go('/feed');
        if (index == 1) context.go('/chat_list');
        if (index == 2) context.go('/profile');
      },
    );
  }
}
