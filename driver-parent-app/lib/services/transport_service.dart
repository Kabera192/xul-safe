import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/session/session_storage.dart';

class TransportService {
  static Future<Map<String, dynamic>> getMyBus() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/me/bus');

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
        throw Exception('Unexpected bus response');
      }
      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load bus'));
  }

  static Future<Map<String, dynamic>> getMyRoute() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/me/bus/route');

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
        throw Exception('Unexpected route response');
      }
      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load route'));
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

      if (message != null && message.isNotEmpty) return message;
      if (error != null && error.isNotEmpty) return error;
    }

    return fallback;
  }

  static Future<Map<String, dynamic>> createMyStop({
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/me/bus/route/stops');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'locationName': locationName.trim(),
        'locationLat': locationLat,
        'locationLong': locationLong,
      }),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected create stop response');
      }
      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to create bus stop'));
  }

  static Future<List<Map<String, dynamic>>> getMyStops() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/me/bus/route/stops');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! List) {
        throw Exception('Unexpected stops response');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load bus stops'));
  }

  static Future<Map<String, dynamic>> updateMyStop({
    required int stopId,
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops/$stopId',
    );

    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'locationName': locationName.trim(),
        'locationLat': locationLat,
        'locationLong': locationLong,
      }),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected update stop response');
      }

      return decoded;
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to update bus stop'),
    );
  }

  static Future<void> deleteMyStop({
    required int stopId,
    required String reason,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/route/stops/$stopId',
    );

    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'reason': reason.trim(),
      }),
    );

    if (res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to delete bus stop'),
    );
  }

  /// GET /api/v1/buses/parent/{parentId}/assigned
  /// Returns { bus: {...}, conductor: { fullName, phoneNumber, photoUrl } }
  /// Returns null when no bus is assigned or on any error.
  static Future<Map<String, dynamic>?> getAssignedBusForParent(
      int parentId) async {
    try {
      final token = await _requireToken();
      final uri =
          Uri.parse('${ApiConfig.baseUrl}/api/v1/buses/parent/$parentId/assigned');
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = _decodeBody(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
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
    final token = await _requireToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/bus-tracking/start');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tripType': tripType,
        'conductorId': conductorId,
        'busId': busId,
        'routeId': routeId,
        'latitude': latitude,
        'longitude': longitude,
      }),
    ).timeout(const Duration(seconds: 10));

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>? ?? decoded;
      }
      throw Exception('Unexpected start journey response');
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to start journey'));
  }

  /// PUT /api/v1/bus-tracking/{journeyId}/location
  static Future<void> updateBusLocation({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    final token = await _requireToken();
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/bus-tracking/$journeyId/location');

    await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    ).timeout(const Duration(seconds: 8));
  }

  /// POST /api/v1/bus-tracking/{journeyId}/end
  static Future<void> endBusJourney(String journeyId) async {
    final token = await _requireToken();
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/bus-tracking/$journeyId/end');

    final res = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200 || res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to end journey'));
  }

}