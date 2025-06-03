import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/services/user_service.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../models/user.dart'; // If you want to use friendId to fetch user data
import '../../widgets/feed_drawer.dart';
import '../../models/friend.dart';
import '../../widgets/bottom_nav_bar.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  bool _loading = true;
  List<Friend> _friends = [];
  Map<int, User> _friendUsers = {}; // <friendId, User>

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await FriendService.getFriends();
      final userMap = <int, User>{};

      // Pobierz User dla każdego friend.friendId
      for (final friend in friends) {
        final user = await UserService.getUserById(friend.userId);
        if (user != null) {
          userMap[friend.friendId] = user;
        }
      }

      setState(() {
        _friends = friends;
        _friendUsers = userMap;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: ${e.toString()}')),
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
        leadingWidth: 80,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                context.go('/feed');
              },
            ),
          ],
        ),
        title: const Text(
          'Moi znajomi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                ? const Center(
              child: Text('Brak znajomych'),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                final user = _friendUsers[friend.friendId];

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: BlobService.buildProfileAvatar(
                        blobId: user?.avatarId ?? 0,
                      ),
                      title: Text(
                        user?.username ?? 'Nieznany użytkownik',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text('ID: ${friend.friendId}'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await FriendService.removeFriend(friend.friendId);
                          _loadFriends();
                        },
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
