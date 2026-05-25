import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/api_config.dart';
import '../core/session/session_storage.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getMyProfile() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile/me');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected profile response');
      }

      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load profile'));
  }

  static Future<Map<String, dynamic>> updateMyProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    final token = await _requireToken();

    final payload = <String, dynamic>{};

    if (firstName != null) payload['firstName'] = firstName.trim();
    if (lastName != null) payload['lastName'] = lastName.trim();
    if (email != null) payload['email'] = email.trim();
    if (phoneNumber != null) payload['phoneNumber'] = phoneNumber.trim();

    if (payload.isEmpty) {
      throw Exception('No profile fields provided');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile/me');

    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected update response');
      }

      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to update profile'));
  }

  static Future<Map<String, dynamic>> uploadMyPhoto(String filePath) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile/me/photo');

    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Detect MIME type from extension; fall back to image/jpeg so the
    // backend's "must start with image/" check always passes for gallery picks
    // (Android cached paths often have no extension).
    final ext = filePath.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected photo upload response');
      }

      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to upload photo'));
  }

  static Future<Uint8List?> getMyPhotoBytes() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile/me/photo');

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return res.bodyBytes;
    }

    if (res.statusCode == 404) {
      return null;
    }

    throw Exception('Failed to fetch photo');
  }

  static Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _requireToken();
    final userId = await SessionStorage.getUserId();
    if (userId == null) throw Exception('Not logged in');

    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/$userId/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (res.statusCode == 200) return;
    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to change password'));
  }

  static Future<String> _requireToken() async {
    final token = await SessionStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No session token found');
    }

    return token;
  }

  static dynamic _decodeBody(String body) {
    final bodyText = body.trim();

    if (bodyText.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(bodyText);
    } catch (_) {
      return null;
    }
  }

  static String _extractErrorMessage(dynamic decoded, String fallback) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message']?.toString();
      final error = decoded['error']?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      if (error != null && error.isNotEmpty) {
        return error;
      }
    }

    return fallback;
  }
}