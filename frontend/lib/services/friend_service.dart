import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/friend.dart';

class FriendService {
  static const _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080') + '/api/v1/friends';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Get current user's accepted friends
  static Future<List<Friend>> getFriends() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['friends'] as List).map((f) => Friend.fromJson(f)).toList();
    } else {
      throw Exception('Nie udało się pobrać listy znajomych');
    }
  }

  /// Get pending invites (sent or received)
  static Future<List<Friend>> getInvites() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/invites"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['invites'] as List).map((f) => Friend.fromJson(f)).toList();
    } else {
      throw Exception('Nie udało się pobrać zaproszeń');
    }
  }

  /// Send an invite to another user by ID
  static Future<void> sendInvite(int inviteeId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/invites"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inviteeId': inviteeId}),
    );

    if (response.statusCode == 200) return;
    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception('Zaproszenie już istnieje: ${data['status']}');
    }
    if (response.statusCode == 404) {
      throw Exception('Nie znaleziono użytkownika');
    }
    throw Exception('Nie udało się wysłać zaproszenia');
  }

  /// Accept a friend invite
  static Future<void> acceptInvite(int inviteeId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/accept"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inviteeId': inviteeId}),
    );

    if (response.statusCode == 200) return;
    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception('Już zaakceptowane: ${data['status']}');
    }
    if (response.statusCode == 404) {
      throw Exception('Zaproszenie nie istnieje');
    }
    throw Exception('Nie udało się zaakceptować zaproszenia');
  }

  /// Reject a friend invite
  static Future<void> rejectInvite(int inviteeId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/reject"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inviteeId': inviteeId}),
    );

    if (response.statusCode == 200) return;
    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception('Nie można odrzucić: ${data['status']}');
    }
    if (response.statusCode == 404) {
      throw Exception('Zaproszenie nie istnieje');
    }
    throw Exception('Nie udało się odrzucić zaproszenia');
  }

  /// Remove a friend
  static Future<void> removeFriend(int friendId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/remove"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'friendId': friendId}),
    );

    if (response.statusCode == 200) return;
    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception('Nie można usunąć: ${data['status']}');
    }
    if (response.statusCode == 404) {
      throw Exception('Znajomość nie istnieje');
    }
    throw Exception('Nie udało się usunąć znajomego');
  }
}
