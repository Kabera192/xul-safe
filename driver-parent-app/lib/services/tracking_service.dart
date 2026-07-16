import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/session/session_storage.dart';

class TrackingService {
  /// GET /api/v1/bus-tracking/child/{childId}
  /// Returns the tracking data map (the `data` field), or null when no active journey.
  static Future<Map<String, dynamic>?> getBusTrackingForChild(
      String childId) async {
    final token = await SessionStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/bus-tracking/child/$childId');

    try {
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = res.body.trim();
        if (body.isEmpty) return null;
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
      // 404 means no active journey — not an error
      return null;
    } catch (_) {
      return null;
    }
  }
}
