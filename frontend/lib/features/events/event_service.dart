// event_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EventService {
  static const _baseUrl = 'http://10.0.2.2:5000/api/v1/events';
  static const _storage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>> getEvents() async {
    final token = await _storage.read(key: 'accessToken');
    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(json['events']);
    } else {
      throw Exception('Nie udało się pobrać wydarzeń');
    }
  }

  static Future<void> reactToEvent(int eventId, bool attending) async {
    // TODO: Zmienić na prawdziwe endpointy gdy będą dostępne w backendzie
    final verb = attending ? 'uczestnictwo' : 'odrzucenie';
    print('Zgłoszono $verb dla wydarzenia $eventId');
    // dodać POST np. /events/{eventId}/attend
  }
}