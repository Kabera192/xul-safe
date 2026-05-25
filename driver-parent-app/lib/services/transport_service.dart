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

}