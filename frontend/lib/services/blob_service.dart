import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/blob.dart';
import '../models/post_blob_request.dart';
import 'package:flutter/material.dart';

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
      return response.bodyBytes; // ✅ Directly return the binary data
    } else {
      throw Exception('Błąd pobierania pliku: ${response.statusCode}');
    }
  }


  static Future<Widget> loadBlobImage(int blobId, {BoxFit fit = BoxFit.cover, double? width, double? height}) async {
  try {
    Uint8List imageData = await BlobService.getBlobData(blobId);
    return Image.memory(
      imageData,
      fit: fit,
      width: width,
      height: height,
    );
  } catch (e) {
    return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
  }
}
  static Widget buildProfileAvatar({required int? blobId, double radius = 90}) {
    return FutureBuilder<Uint8List>(
      future: blobId != null ? BlobService.getBlobData(blobId!) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && blobId != null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            child: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: MemoryImage(snapshot.data!),
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          );
        }
      },
    );
  }
  static Future<void> postBlob(PostBlobRequest request) async {
  final token = await _getToken();

  final uri = Uri.parse(_baseUrl);
  final bodyJson = jsonEncode(request.toJson());
  
  print('POST $uri');
  print('Headers:');
  print({
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });
  print('Request body: $bodyJson');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: bodyJson,
  );

  print('Response status: ${response.statusCode}');
  print('Response headers: ${response.headers}');
  print('Response body: "${response.body}"');

  if (response.statusCode == 200) {
    if (response.body.isNotEmpty) {
      final json = jsonDecode(response.body);
      print('Decoded JSON: $json');
      return json['id']; // assuming backend returns { id: int }
    }
  } else {
    throw Exception('Nie udało się wysłać bloba, status: ${response.statusCode}');
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