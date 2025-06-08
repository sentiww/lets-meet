import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../services/user_service.dart';       // ← dodane
import '../../models/friend.dart';
import '../../models/user.dart';                 // ← dodane
import '../../widgets/feed_drawer.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  bool _loading = true;
  List<Friend> _invites = [];
  final Map<int, String> _usernames = {};  // map userId → username

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    setState(() => _loading = true);
    try {
      final invites = await FriendService.getInvites();
      // Pobierz username dla każdego zaproszenia
      for (final invite in invites) {
        final User? user = await UserService.getUserById(invite.userId);
        _usernames[invite.userId] = user?.username ?? 'Nieznany użytkownik';
      }
      setState(() {
        _invites = invites;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // tylko ikona menu
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        // tapowalne logo w środku
        title: GestureDetector(
          onTap: () => context.go('/feed'),
          child: Image.asset(
            'assets/images/appLogoDark.png',
            height: 32,
            fit: BoxFit.contain,
          ),
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
                : _invites.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Brak nowych zaproszeń',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24),
              itemCount: _invites.length,
              itemBuilder: (context, index) {
                final invite = _invites[index];
                final username = _usernames[invite.userId]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Container(
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading:
                      BlobService.buildProfileAvatar(blobId: 0),
                      title: Text(
                        username,  // ← teraz wyświetla nazwę użytkownika
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Chce zostać Twoim znajomym',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            shape: const CircleBorder(),
                            color: Colors.green.shade600,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 40, height: 40),
                              icon: const Icon(Icons.check,
                                  color: Colors.white),
                              onPressed: () async {
                                await FriendService
                                    .acceptInvite(invite.userId);
                                _loadInvites();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Material(
                            shape: const CircleBorder(),
                            color: Colors.red.shade600,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 40, height: 40),
                              icon: const Icon(Icons.close,
                                  color: Colors.white),
                              onPressed: () async {
                                await FriendService
                                    .rejectInvite(invite.userId);
                                _loadInvites();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
