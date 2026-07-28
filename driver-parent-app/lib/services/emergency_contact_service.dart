import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';
import '../core/session/session_storage.dart';

class EmergencyContactService {
  /// GET /api/v1/emergency-contacts/{parentId}
  static Future<List<Map<String, dynamic>>> getMyContacts() async {
    final userId = await SessionStorage.getUserId();

    if (userId == null) {
      throw Exception('Not logged in');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/emergency-contacts/$userId',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decode(res.body);

    if (res.statusCode == 200) {
      final data = decoded is Map ? decoded['data'] : decoded;

      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }

      return [];
    }

    throw Exception(
      _errorMsg(
        decoded,
        'Failed to load contacts',
      ),
    );
  }

  /// POST /api/v1/emergency-contacts
  static Future<Map<String, dynamic>> addContact({
    required String phoneNumber,
    required String label,
  }) async {
    final userId = await SessionStorage.getUserId();

    if (userId == null) {
      throw Exception('Not logged in');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/emergency-contacts',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('POST', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'phoneNumber': phoneNumber.trim(),
        'label': label.trim(),
        'parentId': userId,
      });

      return request;
    });

    final decoded = _decode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = decoded is Map && decoded['data'] != null
          ? decoded['data']
          : decoded;

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Unexpected response');
    }

    throw Exception(
      _errorMsg(
        decoded,
        'Failed to add contact',
      ),
    );
  }

  /// DELETE /api/v1/emergency-contacts/{parentId}/{contactId}
  static Future<void> deleteContact(int contactId) async {
    final userId = await SessionStorage.getUserId();

    if (userId == null) {
      throw Exception('Not logged in');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/emergency-contacts/$userId/$contactId',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('DELETE', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    }

    final decoded = _decode(res.body);

    throw Exception(
      _errorMsg(
        decoded,
        'Failed to delete contact',
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  static dynamic _decode(String body) {
    final t = body.trim();

    if (t.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(t);
    } catch (_) {
      return null;
    }
  }

  static String _errorMsg(
    dynamic decoded,
    String fallback,
  ) {
    if (decoded is Map<String, dynamic>) {
      final m = decoded['message']?.toString();
      final e = decoded['error']?.toString();

      if (m != null && m.isNotEmpty) {
        return m;
      }

      if (e != null && e.isNotEmpty) {
        return e;
      }
    }

    return fallback;
  }
}