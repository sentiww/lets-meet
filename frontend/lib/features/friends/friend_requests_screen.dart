import 'package:flutter/material.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../widgets/feed_drawer.dart';
import '../../models/friend.dart';
import '../../widgets/bottom_nav_bar.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  bool _loading = true;
  List<Friend> _invites = [];

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    try {
      final invites = await FriendService.getInvites();
      setState(() {
        _invites = invites;
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
        title: const Text('Zaproszenia do znajomych'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _invites.isEmpty
              ? const Center(child: Text('Brak zaproszeń'))
              : ListView.builder(
                  itemCount: _invites.length,
                  itemBuilder: (context, index) {
                    final invite = _invites[index];
                    return ListTile(
                      leading: BlobService.buildProfileAvatar(blobId: 0),//invite.userId), // Could be inviteeId depending on direction
                      title: Text(invite.userId.toString() + 'To change'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              await FriendService.acceptInvite(invite.userId);
                              _loadInvites();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await FriendService.rejectInvite(invite.userId);
                              _loadInvites();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
