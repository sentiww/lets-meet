import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/event.dart';
import '../models/post_event_request.dart';

class EventService {
  static const _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080') + '/api/v1/events';
  static const _storage = FlutterSecureStorage();
  static List<Event> TEST_events = [
  Event(id:0,title: 'Koncert Jazzowy', description: 'Opis koncertu jazzowego', eventDate: DateTime.now()),
  Event(id:1,title: 'Warsztaty Codingowe', description: 'Opis warsztatów codingowych', eventDate: DateTime.now()),
  Event(id:2,title: 'Teatr', description: 'Opis przedstawienia teatralnego', eventDate: DateTime.now()),
  ];
  static int TEST_freeID = 3;


  static Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  static Future<List<Event>> getEvents() async {
    return TEST_events;
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
      final events = (data['events'] as List)
          .map((e) => Event.fromJson(e))
          .toList();
      return events;
    } else {
      print('Błąd getEvents: ${response.statusCode} - ${response.body}');
      throw Exception('Nie udało się pobrać wydarzeń');
    }
  }

  static Future<Event?> getEvent(int id) async {
    final event = TEST_events.firstWhere(
      (event) => event.id == id,
      orElse: () => throw Exception('TEST: Event with id $id not found!'),
    );
    return event;
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Event.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Błąd getEvent: ${response.statusCode}');
    }
  }

  static Future<void> postEvent(PostEventRequest request) async {
    /*Event TEST_newEvent = new Event(
      id: TEST_freeID++,
      title: request.title,
      description: request.description,
      eventDate: request.eventDate,
      photoIds: request.photoBlobIds);
    TEST_events.add(TEST_newEvent);
    return;
    */
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się dodać wydarzenia');
    }
  }

  static Future<void> updateEvent(int id, PostEventRequest request) async {
    int index = TEST_events.indexWhere((event) => event.id == id);
  
    if (index != -1) {
      // Znaleziono wydarzenie, aktualizujemy jego tytuł i opis
      Event TEST_replacement = new Event(
      id: id,
      title: request.title,
      description: request.description,
      photoIds: request.photoBlobIds);
    TEST_events[index] = TEST_replacement;   
    } else {
      print('TEST: Event with id $id not found!');
    }
    return;
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$_baseUrl/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się zaktualizować wydarzenia');
    }
  }

  static Future<void> deleteEvent(int id) async {
    int index = TEST_events.indexWhere((event) => event.id == id);

    if (index != -1) {
      // Usuwamy wydarzenie
      TEST_events.removeAt(index);
      print('Wydarzenie o ID $id zostało usunięte');
    } else {
      print('TEST: Event with id $id not found!');
    }
    return;
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$_baseUrl/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) return;
    if (response.statusCode == 403) throw Exception('Brak uprawnień');
    if (response.statusCode == 404) throw Exception('Nie znaleziono wydarzenia');

    throw Exception('Błąd usuwania: ${response.statusCode}');
  }
}
