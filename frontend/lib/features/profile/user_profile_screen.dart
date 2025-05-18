// user_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final token = await _storage.read(key: 'accessToken');
    final res = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/v1/users/${widget.userId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() => _user = jsonDecode(res.body));
    }
    setState(() => _loading = false);
  }

  Future<void> _sendFriendRequest() async {
    final token = await _storage.read(key: 'accessToken');
    final res = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/v1/friends/invite'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'inviteeId': widget.userId}),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.statusCode == 200 ? 'Zaproszono do znajomych' : 'Już zaproszono lub błąd')),
    );
  }

  Future<void> _blockUser() async {
    final token = await _storage.read(key: 'accessToken');
    final res = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/v1/block/${widget.userId}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.statusCode == 204 ? 'Użytkownik zablokowany' : 'Błąd blokowania')),
    );
  }

  void _goToChat() {
    context.go('/chat/${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        width: 390,
        height: 844,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 68,
              top: 106,
              child: Container(
                width: 255,
                height: 255,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFEADDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: _user?["avatarUrl"] != null
                    ? ClipOval(
                  child: Image.network(
                    _user!["avatarUrl"],
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.person, size: 120, color: Colors.deepPurple),
              ),
            ),
            Positioned(
              left: 34,
              top: 378,
              child: SizedBox(
                width: 322,
                child: Center(
                  child: Text(
                    "${_user?["name"] ?? ""} ${_user?["surname"] ?? ""}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 37,
              top: 443,
              child: SizedBox(
                width: 316,
                child: Center(
                  child: Text(
                    _user?["dateOfBirth"]?.substring(0, 10) ?? "",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 65,
              top: 523,
              child: GestureDetector(
                onTap: _sendFriendRequest,
                child: Container(
                  width: 260,
                  height: 54,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBA68C8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Send Friend Request', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            Positioned(
              left: 65,
              top: 594,
              child: GestureDetector(
                onTap: _goToChat,
                child: Container(
                  width: 260,
                  height: 54,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE7CAEC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Send Message', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            Positioned(
              left: 118,
              top: 677,
              child: GestureDetector(
                onTap: _blockUser,
                child: Container(
                  width: 155,
                  height: 54,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE85959),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Block', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}