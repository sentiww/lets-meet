import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/blob.dart';
import '../models/post_blob_request.dart';

class BlobService {
  static const _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080') + '/api/v1/blobs';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  static Future<List<BlobInfo>> getBlobs() async {
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
      return (data['blobs'] as List)
          .map((e) => BlobInfo.fromJson(e))
          .toList();
    } else {
      throw Exception('Nie udało się pobrać blobów');
    }
  }

  static Future<Uint8List> getBlobData(int blobId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/$blobId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Błąd pobierania pliku: ${response.statusCode}');
    }
  }

  static Future<void> postBlob(PostBlobRequest request) async {
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
      throw Exception('Nie udało się wysłać bloba');
    }
  }

  static Future<void> deleteBlob(int blobId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$_baseUrl/$blobId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się usunąć bloba');
    }
  }
}
