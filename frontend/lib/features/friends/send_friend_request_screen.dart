import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../models/user.dart';
import '../../widgets/feed_drawer.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  Future<void> _sendInvite(int friendId) async {
    try {
      await FriendService.sendInvite(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaproszenie wysłane')),
      );
      _manualController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tylko ikona menu po lewej
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        // Logo na środku, tap przenosi do feedu
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ręczne ID
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wyślij zaproszenie ręcznie (ID):',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _manualController,
                                  decoration: InputDecoration(
                                    hintText: 'Wpisz ID użytkownika',
                                    prefixIcon: const Icon(Icons.person_outline,
                                        color: Color(0xFF6A1B9A)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6A1B9A)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6A1B9A)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  try {
                                    final friendId = int.parse(
                                        _manualController.text.trim());
                                    _sendInvite(friendId);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Błąd: $e')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B9A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                child:
                                const Icon(Icons.send, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 1, height: 0),
                  const SizedBox(height: 24),

                  // Pole szukania
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Szukaj użytkownika',
                      labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                      prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF6A1B9A)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                  const SizedBox(height: 16),

                  // Wyniki
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                    child: _results.isEmpty
                        ? Center(
                      child: Text(
                        'Brak wyników',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                        : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: BlobService.buildProfileAvatar(
                              blobId: user.avatarId,
                            ),
                            title: Text(
                              '${user.name} ${user.surname}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('@${user.username}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add,
                                  color: Colors.green),
                              onPressed: () => _sendInvite(user.id),
                            ),
                          ),
                        );
                      },
                    ),
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
