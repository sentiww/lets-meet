import 'package:flutter/material.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../widgets/bottom_nav_bar.dart';

class SendFriendRequestScreen extends StatefulWidget {
  const SendFriendRequestScreen({super.key});

  @override
  State<SendFriendRequestScreen> createState() => _SendFriendRequestScreenState();
}

class _SendFriendRequestScreenState extends State<SendFriendRequestScreen> {
  final TextEditingController _manualController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<User> _results = [];
  bool _loading = false;

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    try {
      // final users = await UserService.searchUsers(query); // Uncomment when ready
      setState(() {
        // _results = users; // Uncomment when ready
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  Future<void> _sendInvite(int friendId) async {
    try {
      await FriendService.sendInvite(friendId); // friendId as string
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaproszenie wysłane')),
      );
      _manualController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      appBar: AppBar(title: const Text('Dodaj znajomego')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual Friend ID Entry
            const Text(
              'Wyślij zaproszenie ręcznie (friendId):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    decoration: const InputDecoration(
                      hintText: 'Wpisz friendId',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    try
                    {
                      final friendId = int.parse(_manualController.text.trim());
                      _sendInvite(friendId);
                    }
                     catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
                    }
                  },
                  child: const Text('Wyślij'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            // Search Field
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Szukaj po nazwie użytkownika',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchUsers(),
            ),
            const SizedBox(height: 20),

            // Results List
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return ListTile(
                          leading: BlobService.buildProfileAvatar(blobId: user.avatarId),
                          title: Text('${user.name} ${user.surname} (@${user.username})'),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.green),
                            onPressed: () => {}, //_sendInvite(user.id.toString()),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
