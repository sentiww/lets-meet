import 'dart:convert'; // For handling UTF-8

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
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
            ? const Center(child: CircularProgressIndicator()) // Loading indicator
            : _user == null
            ? const Center(child: Text('Błąd ładowania profilu')) // Error message
            : Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _user!.avatarUrl != null
                    ? NetworkImage(_user!.avatarUrl!)
                    : null,
                child: _user!.avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 34),
            _ProfileInfoTile(
              label: 'Imię i nazwisko',
              value: utf8.decode('${_user!.name} ${_user!.surname}'.runes.toList()),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await context.push<bool>('/editProfile');
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
      bottomNavigationBar: const _BottomNavBar(currentIndex: 2),
    );
  }
}

// Widget for displaying user info tile
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
                  Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom navigation bar for navigation between screens
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
          label: 'Odkrywaj', // Discover
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Wiadomości', // Messages
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil', // Profile
        ),
      ],
      onTap: (index) {
        if (index == 0) context.go('/feed');
        if (index == 1) context.go('/messages');
        if (index == 2) context.go('/myProfile');
      },
    );
  }
}
