import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UserService {
  // Base URL for the user-related API endpoints
  static const _baseUrl = 'http://10.0.2.2:5000/api/v1/users';

  // Secure storage for storing and retrieving the access token
  static const _storage = FlutterSecureStorage();

  // Fetches the currently authenticated user from the backend
  static Future<User?> getCurrentUser() async {
    // Read the access token from secure storage
    final token = await _storage.read(key: 'accessToken');
    if (token == null) return null;

    // Make a GET request to fetch user data
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token', // Pass token in Authorization header
        'Content-Type': 'application/json',
      },
    );

    // If request is successful, decode and return User object
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      // Log error details to the console if request fails
      print('Błąd getCurrentUser: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
