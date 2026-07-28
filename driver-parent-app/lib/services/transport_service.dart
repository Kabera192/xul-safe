import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';

class TransportService {
  static Future<Map<String, dynamic>> getMyBus() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected bus response');
      }

      return decoded;
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load bus',
      ),
    );
  }

  static Future<Map<String, dynamic>> getMyRoute() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected route response');
      }

      return decoded;
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load route',
      ),
    );
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

  static String _extractErrorMessage(
    dynamic decoded,
    String fallback,
  ) {
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

  static Future<Map<String, dynamic>> createMyStop({
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('POST', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'locationName': locationName.trim(),
        'locationLat': locationLat,
        'locationLong': locationLong,
      });

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected create stop response');
      }

      return decoded;
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to create bus stop',
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> getMyStops() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! List) {
        throw Exception('Unexpected stops response');
      }

      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load bus stops',
      ),
    );
  }

  static Future<Map<String, dynamic>> updateMyStop({
    required int stopId,
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops/$stopId',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('PATCH', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'locationName': locationName.trim(),
        'locationLat': locationLat,
        'locationLong': locationLong,
      });

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected update stop response');
      }

      return decoded;
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to update bus stop',
      ),
    );
  }

  static Future<void> deleteMyStop({
    required int stopId,
    required String reason,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops/$stopId',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('DELETE', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'reason': reason.trim(),
      });

      return request;
    });

    if (res.statusCode == 204) {
      return;
    }

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to delete bus stop',
      ),
    );
  }

  /// GET /api/v1/buses/parent/{parentId}/assigned
  /// Returns { bus: {...}, conductor: { fullName, phoneNumber, photoUrl } }
  /// Returns null when no bus is assigned or on any error.
  static Future<Map<String, dynamic>?> getAssignedBusForParent(
    int parentId,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/buses/parent/$parentId/assigned',
      );

      final res = await AuthenticatedHttpClient.send(() async {
        final request = http.Request('GET', uri);
        request.headers['Content-Type'] = 'application/json';

        return request;
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = _decodeBody(res.body);

        if (decoded is Map<String, dynamic>) {
          // Backend wraps response in ApiResponse { message, data }
          final inner = decoded['data'];

          if (inner is Map<String, dynamic>) {
            return inner;
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// POST /api/v1/bus-tracking/start
  /// Returns the tracking record (including `id` used for subsequent calls).
  static Future<Map<String, dynamic>> startBusJourney({
    required String tripType,
    required int conductorId,
    required int busId,
    required int routeId,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/bus-tracking/start',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('POST', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'tripType': tripType,
        'conductorId': conductorId,
        'busId': busId,
        'routeId': routeId,
        'latitude': latitude,
        'longitude': longitude,
      });

      return request;
    }).timeout(const Duration(seconds: 10));

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>? ?? decoded;
      }

      throw Exception('Unexpected start journey response');
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to start journey',
      ),
    );
  }

  /// PUT /api/v1/bus-tracking/{journeyId}/location
  static Future<void> updateBusLocation({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/bus-tracking/$journeyId/location',
    );

    await AuthenticatedHttpClient.send(() async {
      final request = http.Request('PUT', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      });

      return request;
    }).timeout(const Duration(seconds: 8));
  }

  /// POST /api/v1/bus-tracking/{journeyId}/end
  static Future<void> endBusJourney(String journeyId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/bus-tracking/$journeyId/end',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    }).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    }

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to end journey',
      ),
    );
  }
}