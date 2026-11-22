import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';

/// Thrown when a tracking poll couldn't actually reach the server (network
/// error, timeout, malformed response) — distinct from the server
/// confirming there's simply no active journey (a clean 404/empty body).
class TrackingPollFailedException implements Exception {
  final Object cause;
  const TrackingPollFailedException(this.cause);

  @override
  String toString() => 'TrackingPollFailedException: $cause';
}

class TrackingService {
  /// GET /api/v1/bus-tracking/child/{childId}
  /// Returns the tracking data map (the `data` field), or null when the
  /// server confirms there's no active journey. Throws
  /// [TrackingPollFailedException] if the poll itself failed (network error,
  /// timeout, bad response) — callers must not treat that the same as a
  /// confirmed "no active journey".
  static Future<Map<String, dynamic>?> getBusTrackingForChild(
    String childId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/bus-tracking/child/$childId',
    );

    http.Response res;
    try {
      res = await AuthenticatedHttpClient.send(() async {
        final request = http.Request('GET', uri);

        request.headers['Content-Type'] = 'application/json';

        return request;
      }).timeout(const Duration(seconds: 8));
    } catch (e) {
      throw TrackingPollFailedException(e);
    }

    if (res.statusCode == 200) {
      final body = res.body.trim();

      if (body.isEmpty) {
        return null;
      }

      try {
        final decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      } catch (e) {
        throw TrackingPollFailedException(e);
      }

      return null;
    }

    if (res.statusCode == 404) {
      // The server has confirmed there's no active journey — not an error.
      return null;
    }

    throw TrackingPollFailedException('HTTP ${res.statusCode}');
  }
}