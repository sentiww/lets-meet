import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../services/blob_service.dart';

class ChatFriendListScreen extends StatefulWidget {
  final int chatId;

  const ChatFriendListScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatFriendListScreen> createState() => _ChatFriendListScreenState();
}

class _ChatFriendListScreenState extends State<ChatFriendListScreen> {
  bool _loading = true;
  String? _error;
  List<_ChatParticipant> _participants = [];

  @override
  void initState() {
    super.initState();
    _fetchChatParticipants();
  }

  Future<void> _fetchChatParticipants() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        context.go('/'); // przekierowanie do logowania
        return;
      }

      final uri = Uri.parse(
        'http://localhost:8080/api/v1/chats/${widget.chatId}',
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final userIdsJson = data['userIds'] as List<dynamic>?;
        if (userIdsJson == null) {
          setState(() {
            _error = 'Niepoprawna odpowiedź: brakuje pola userIds';
            _loading = false;
          });
          return;
        }

        final List<int> userIds = userIdsJson
            .map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? -1)
            .where((id) => id != -1)
            .toList();

        if (userIds.isEmpty) {
          setState(() {
            _error = 'Lista uczestników jest pusta';
            _loading = false;
          });
          return;
        }

        final List<_ChatParticipant> loaded = [];
        for (final id in userIds) {
          final user = await UserService.getUserById(id);
          if (user != null) {
            loaded.add(_ChatParticipant(
              id: id,
              username: user.username,
              avatarId: user.avatarId,
            ));
          } else {
            loaded.add(_ChatParticipant(
              id: id,
              username: 'User $id',
              avatarId: null,
            ));
          }
        }

        setState(() {
          _participants = loaded;
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        final refreshed = await AuthService.refreshToken();
        if (!refreshed) {
          context.go('/');
          return;
        }
        await _fetchChatParticipants();
      } else {
        setState(() {
          _error = 'Błąd serwera: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Wyjątek przy pobieraniu uczestników: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.go('/chat_conversation/${widget.chatId}');
          },
        ),
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
    if (_participants.isEmpty) {
      return Center(
        child: Text(
          'Brak uczestników w tym czacie.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Uczestnicy czatu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _participants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = _participants[index];
              return _FriendTile(
                username: user.username,
                id: user.id,
                avatarColor: Colors.blue,
                avatarId: user.avatarId,
                onTap: () {
                  // przekazujemy oba parametry: chatId i userId
                  context.go(
                    '/other-profile/${widget.chatId}/${user.id}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChatParticipant {
  final int id;
  final String username;
  final int? avatarId;

  _ChatParticipant({
    required this.id,
    required this.username,
    this.avatarId,
  });
}

class _FriendTile extends StatelessWidget {
  final String username;
  final int id;
  final Color avatarColor;
  final int? avatarId;
  final VoidCallback onTap;

  const _FriendTile({
    Key? key,
    required this.username,
    required this.id,
    required this.avatarColor,
    required this.onTap,
    this.avatarId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;
    if (avatarId != null) {
      avatarWidget = FutureBuilder<Widget>(
        future: BlobService.loadBlobImage(avatarId!),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: const CircularProgressIndicator(),
            );
          } else if (snap.hasData) {
            return CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: snap.data,
                ),
              ),
            );
          } else {
            return CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Icon(Icons.person, color: avatarColor, size: 24),
            );
          }
        },
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 20,
        backgroundColor: avatarColor.withOpacity(0.2),
        child: Icon(Icons.person, color: avatarColor, size: 24),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            avatarWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$username (id: $id)',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
