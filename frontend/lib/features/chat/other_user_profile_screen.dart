import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/user_service.dart';
import '../../services/friend_service.dart';
import '../../models/user.dart';
import '../../services/blob_service.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  final int chatId;

  const OtherUserProfileScreen({
    Key? key,
    required this.userId,
    required this.chatId,
  }) : super(key: key);

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  bool _loading = true;
  String? _error;
  User? _user;
  bool _isFriend = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAndStatus();
  }

  Future<void> _fetchUserAndStatus() async {
    try {
      final fetched = await UserService.getUserById(widget.userId);
      if (fetched == null) {
        setState(() {
          _error = 'Nie znaleziono użytkownika o ID ${widget.userId}';
          _loading = false;
        });
        return;
      }

      bool isFriend = false;
      try {
        final friends = await FriendService.getFriends();
        isFriend = friends.any((f) =>
        f.userId == widget.userId || f.friendId == widget.userId);
      } catch (_) {
        isFriend = false;
      }

      bool isBlocked = false;

      setState(() {
        _user = fetched;
        _isFriend = isFriend;
        _isBlocked = isBlocked;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Błąd przy pobieraniu profilu: $e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFriendStatus() async {
    if (_isFriend) {
      try {
        await FriendService.removeFriend(widget.userId);
        setState(() => _isFriend = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się usunąć ze znajomych: $e')),
        );
      }
    } else {
      try {
        await FriendService.sendInvite(widget.userId);
        setState(() => _isFriend = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się wysłać zaproszenia: $e')),
        );
      }
    }
  }

  Future<void> _toggleBlockStatus() async {
    try {
      final success = await UserService.toggleUserBan(widget.userId);
      if (success) {
        setState(() => _isBlocked = !_isBlocked);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się zmienić statusu blokady')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd przy blokowaniu/odblokowywaniu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- AppBar z przyciskiem powrotu ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Powrót do ChatFriendList dla chatId:
            context.go('/chat_friend_list/${widget.chatId}');
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_user == null) {
      return Center(
        child: Text(
          'Brak danych o użytkowniku.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    final user = _user!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Awatar ---
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: FutureBuilder<Widget>(
              future: user.avatarId != null
                  ? BlobService.loadBlobImage(user.avatarId!)
                  : Future.value(
                  const Icon(Icons.person, size: 80, color: Color(0xFF6A1B9A))),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: snapshot.data,
                    ),
                  );
                } else {
                  return const Icon(Icons.person, size: 80, color: Color(0xFF6A1B9A));
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- Username i ID ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                color: Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${user.username} (id: ${user.id})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- Przycisk: Dodaj do znajomych / Usuń ze znajomych ---
          ElevatedButton.icon(
            onPressed: _toggleFriendStatus,
            icon: Icon(
              _isFriend ? Icons.person_remove : Icons.person_add,
              color: Colors.white,
            ),
            label: Text(
              _isFriend ? 'Usuń ze znajomych' : 'Dodaj do znajomych',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _isFriend ? Colors.grey.shade700 : const Color(0xFF6A1B9A),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Przycisk: Wyślij wiadomość ---
          SizedBox(
            width: 250,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/chat_list');
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black87,
              ),
              label: const Text(
                'Wyślij wiadomość',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1BEE7),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Przycisk: Zablokuj / Odblokuj ---
          SizedBox(
            width: 250,
            child: ElevatedButton.icon(
              onPressed: _toggleBlockStatus,
              icon: Icon(
                _isBlocked ? Icons.lock_open : Icons.block,
                color: Colors.white,
              ),
              label: Text(
                _isBlocked ? 'Odblokuj' : 'Zablokuj',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _isBlocked ? Colors.green.shade600 : Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
