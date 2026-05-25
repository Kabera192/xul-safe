import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/session/session_storage.dart';
import '../features/driver/models/attendance_record_model.dart';

class AttendanceService {
  /// GET /api/v1/me/bus/attendance?date=yyyy-MM-dd&session=MORNING|AFTERNOON
  ///
  /// Returns all bus students with their confirmed status for the given session.
  static Future<List<AttendanceRecordModel>> getSessionAttendance({
    required DateTime date,
    required String session,
  }) async {
    final token = await _requireToken();
    final dateText = _formatDate(date);

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/attendance'
      '?date=$dateText&session=$session',
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! List) throw Exception('Unexpected attendance response');
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AttendanceRecordModel.fromJson)
          .toList();
    }

    throw Exception(
        _extractErrorMessage(decoded, 'Failed to load attendance'));
  }

  /// POST /api/v1/me/bus/attendance/mark
  ///
  /// Upserts one attendance event for a student.
  /// [action] must be 'BOARDED' or 'DROPPED_OFF'.
  static Future<AttendanceRecordModel> markAttendance({
    required String childId,
    required DateTime date,
    required String session,
    required String action,
    required bool confirmed,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/attendance/mark',
    );

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'childId': childId,
        'date': _formatDate(date),
        'session': session,
        'action': action,
        'confirmed': confirmed,
      }),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected mark-attendance response');
      }
      return AttendanceRecordModel.fromJson(decoded);
    }

    throw Exception(
        _extractErrorMessage(decoded, 'Failed to save attendance'));
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<String> _requireToken() async {
    final token = await SessionStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No session token found');
    }
    return token;
  }

  static dynamic _decodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }

  static String _extractErrorMessage(dynamic decoded, String fallback) {
    if (decoded is Map) {
      return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
    }
    return fallback;
  }
}
