import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080') + '/api/v1/users';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async => await _storage.read(key: 'accessToken');

  // Get current authenticated user
  static Future<User?> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      print('Błąd getCurrentUser: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
  
  // Update current user (PUT /me)
  static Future<bool> updateCurrentUser({
    required String name,
    required String surname,
    required DateTime dateOfBirth,
    required String email,
    int? avatarId,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = jsonEncode({
      'name': name,
      'surname': surname,
      'dateOfBirth': dateOfBirth.toUtc().toIso8601String(),
      'email': email,
      'avatarId': avatarId,
    });

    final response = await http.put(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Błąd updateCurrentUser: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Get user by ID (GET /{id})
  static Future<User?> getUserById(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      print('Błąd getUserById: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  // Toggle ban status (PUT /{id}/toggle-ban)
  static Future<bool> toggleUserBan(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/$id/toggle-ban'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Błąd toggleUserBan: ${response.statusCode} - ${response.body}');
      return false;
    }
  }


}
