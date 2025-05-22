import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await FriendService.getFriends();
      setState(() {
        _friends = friends;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      drawer: const FeedDrawer(),
      appBar: AppBar(
        title: const Text('Moi znajomi'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? const Center(child: Text('Brak znajomych'))
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return ListTile(
                      //UserService.getUserById(friend.userId)
                      leading: BlobService.buildProfileAvatar(blobId: 0),//friend.friendId), // replace with real avatar if available
                      title: Text(friend.friendId.toString() + 'To change'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () async {
                          await FriendService.removeFriend(friend.friendId);
                          _loadFriends();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
