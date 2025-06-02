import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Service responsible for authentication logic (login, registration, tokens)
class AuthService {
  static const _baseUrl = String.fromEnvironment('BASE_URL',
      defaultValue: 'http://localhost:8080') +
      '/api/v1/auth';
  static const _storage = FlutterSecureStorage();

  /// Sign in user with username and password
  static Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/signin');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Store tokens securely
        await _storage.write(key: 'accessToken', value: body['token']);
        await _storage.write(key: 'refreshToken', value: body['refreshToken']);
        return true;
      } else if (res.statusCode == 401) {
        // Unauthorized
        return false;
      } else {
        // Unexpected error
        throw Exception('Login failed (${res.statusCode})');
      }
    } catch (e) {
      // Rethrow for global handling
      rethrow;
    }
  }

  /// Sign up a new user with full details
  static Future<bool> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
    required String surname,
    required DateTime dateOfBirth,
    required void Function(Map<String, String> fieldErrors) onFieldErrors,
  }) async {
    final uri = Uri.parse('$_baseUrl/signup');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'name': name,
          'surname': surname,
          'dateOfBirth': dateOfBirth.toIso8601String(),
        }),
      );

      if (res.statusCode == 200) {
        // Registration successful
        return true;
      } else if (res.statusCode == 400) {
        // Validation error response
        final body = jsonDecode(res.body);
        final errors = <String, String>{};

        if (body is Map && body.containsKey('errors')) {
          final errorMap = body['errors'] as Map<String, dynamic>;
          for (final entry in errorMap.entries) {
            final key = entry.key;
            final messages = entry.value;
            if (messages is List && messages.isNotEmpty) {
              errors[key] = messages.first.toString();
            }
          }
        }

        // Return field-specific errors
        onFieldErrors(errors);
        return false;
      } else {
        return false;
      }
    } catch (e) {
      // Network or unexpected error
      return false;
    }
  }

  /// Get stored access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Remove all stored tokens (logout)
  static Future<void> signOut() async {
    await _storage.deleteAll();
  }

  /// Attempt to refresh the access token using stored refresh token
  static Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: 'refreshToken');
    if (refresh == null) return false;

    final uri = Uri.parse('$_baseUrl/refresh');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refresh}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Save new tokens
        await _storage.write(key: 'accessToken', value: body['token']);
        await _storage.write(key: 'refreshToken', value: body['refreshToken']);
        return true;
      } else {
        // Refresh failed, clear session
        await signOut();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Decode JWT payload and extract user ID from "oid" claim (or "sub")
  static Future<int?> getCurrentUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Decode Base64Url payload
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> jsonMap = jsonDecode(payload);

    // JWT "oid" claim holds user ID; fallback to "sub"
    if (jsonMap.containsKey('oid')) {
      return int.tryParse(jsonMap['oid'].toString());
    } else if (jsonMap.containsKey('sub')) {
      return int.tryParse(jsonMap['sub'].toString());
    }
    return null;
  }
}
