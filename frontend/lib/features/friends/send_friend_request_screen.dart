import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/friend_service.dart';
import '../../services/blob_service.dart';
import '../../models/user.dart';
import '../../widgets/feed_drawer.dart';

class SendFriendRequestScreen extends StatefulWidget {
  const SendFriendRequestScreen({super.key});

  @override
  State<SendFriendRequestScreen> createState() =>
      _SendFriendRequestScreenState();
}

class _SendFriendRequestScreenState extends State<SendFriendRequestScreen> {
  final _manualController = TextEditingController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<User> _results = [];
  bool _loading = false;
  int? _myId;

  @override
  void initState() {
    super.initState();
    AuthService.getCurrentUserId().then((id) {
      setState(() => _myId = id);
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _searchController.text.trim();
      if (q.isNotEmpty) {
        _searchUsers(q);
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getAccessToken();
      final myId = _myId;
      if (token == null || myId == null) throw Exception('Brak autoryzacji');

      const base = String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'http://localhost:8080',
      );
      final uri = Uri.parse('$base/api/v1/users');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (resp.statusCode != 200) {
        throw Exception('Błąd serwera: ${resp.statusCode}');
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = (body['users'] as List).map((u) => User.fromJson(u)).toList();
      final low = query.toLowerCase();
      final filtered = list.where((u) {
        final matches = u.username.toLowerCase().contains(low);
        return matches && u.id != myId;
      }).toList();

      setState(() => _results = filtered);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas wyszukiwania: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendInvite(int friendId) async {
    if (_myId != null && friendId == _myId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie możesz wysłać zaproszenia do siebie')),
      );
      return;
    }
    try {
      await FriendService.sendInvite(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaproszenie wysłane')),
      );
      _manualController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
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
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ręczne pole ID
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _manualController,
                              decoration: InputDecoration(
                                hintText: 'Wpisz ID użytkownika',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF6A1B9A),
                                ),
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
                                final id = int.parse(
                                    _manualController.text.trim());
                                _sendInvite(id);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Błąd: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            child: const Icon(Icons.send,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(thickness: 1, height: 0),
                  const SizedBox(height: 24),

                  // Live search field
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Szukaj użytkownika',
                        prefixIcon: Icon(Icons.search,
                            color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wyniki wyszukiwania
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
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
                        padding:
                        const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return Material(
                            color: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                Colors.grey.shade300,
                                child: BlobService.buildProfileAvatar(
                                    blobId: user.avatarId),
                              ),
                              title: Text(
                                '@${user.username}',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.person_add,
                                    color: Colors.green),
                                onPressed: () =>
                                    _sendInvite(user.id),
                              ),
                              onTap: () => _sendInvite(user.id),
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
