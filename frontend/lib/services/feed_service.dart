import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lets_meet/services/auth_service.dart';

import '../models/feed_event.dart';
import '../models/liked_events_response.dart';

class FeedService {
  static const String _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080') + '/api/v1/feed';

  /// Fetch a random feed event
  static Future<FeedEvent?> fetchFeedEvent() async {
    final token = await AuthService.getAccessToken();

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return null;
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FeedEvent.fromJson(data);
    }

    throw Exception('Failed to fetch feed event');
  }

  /// Fetch events liked by the current user
  static Future<List<int>> fetchLikedEventIds() async {
    final token = await AuthService.getAccessToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/liked'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final likedEvents = LikedEventsResponse.fromJson(jsonData);
      return likedEvents.events.map((e) => e.eventId).toList();
    }

    throw Exception('Failed to fetch liked events');
  }

  /// Like an event by ID
  static Future<void> likeEvent(int eventId) async {
    final token = await AuthService.getAccessToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) return;

    if (response.statusCode == 404) {
      throw Exception('Event not found');
    }

    throw Exception('Failed to like event');
  }
}
