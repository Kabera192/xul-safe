import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/api_config.dart';
import '../core/session/session_storage.dart';

class ChildService {
  static Future<List<Map<String, dynamic>>> getMyBusChildren() async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/me/bus/children');

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
        throw Exception('Unexpected children response');
      }

      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load children'));
  }

  static Future<Map<String, dynamic>> getMyBusChildById(int childId) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/children/$childId',
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
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected child detail response');
      }

      return decoded;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load child'));
  }

  static Future<List<Map<String, dynamic>>> getAbsentChildren({
    required DateTime date,
    required String journey,
  }) async {
    final token = await _requireToken();

    final dateText = _formatDate(date);

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/children/absent'
      '?date=$dateText&journey=$journey',
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
      if (decoded is! List) {
        throw Exception('Unexpected absent children response');
      }

      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to load absent children'),
    );
  }

  static Future<void> assignChildrenToStop({
    required int stopId,
    required List<int> childIds,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/me/bus/children/assign-to-stop/$stopId',
    );

    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'childIds': childIds,
      }),
    );

    if (res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to assign children'),
    );
  }

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

  // ── Parent children endpoints ─────────────────────────────────────────────

  /// GET /api/v1/children?parent_id={userId}
  /// Returns the list of children belonging to the logged-in parent.
  static Future<List<Map<String, dynamic>>> getMyChildren() async {
    final token = await _requireToken();
    final userId = await SessionStorage.getUserId();
    if (userId == null) throw Exception('Not logged in');

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/children?parent_id=$userId',
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
      final data = decoded is Map ? decoded['data'] : decoded;
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load children'));
  }

  /// POST /api/v1/children
  /// Creates a new child linked to the logged-in parent.
  static Future<Map<String, dynamic>> addChild({
    required String fullName,
    String? birthDate,
    String? gender,
    String? grade,
  }) async {
    final token = await _requireToken();
    final userId = await SessionStorage.getUserId();
    if (userId == null) throw Exception('Not logged in');

    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      'parentId': userId,
    };
    if (birthDate != null && birthDate.isNotEmpty) payload['birthDate'] = birthDate;
    if (gender != null && gender.isNotEmpty) payload['gender'] = gender;
    if (grade != null && grade.isNotEmpty) payload['grade'] = grade;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = decoded is Map && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) return data;
      throw Exception('Unexpected response');
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to add child'));
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

  // ── Child CRUD ────────────────────────────────────────────────────────────

  /// PUT /api/v1/children/{childId}
  static Future<void> updateChild({
    required String childId,
    required String fullName,
    String? birthDate,
    String? gender,
    String? grade,
  }) async {
    final token = await _requireToken();
    final userId = await SessionStorage.getUserId();
    if (userId == null) throw Exception('Not logged in');

    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      'parentId': userId,
    };
    if (birthDate != null && birthDate.isNotEmpty) payload['birthDate'] = birthDate;
    if (gender != null && gender.isNotEmpty) payload['gender'] = gender;
    if (grade != null && grade.isNotEmpty) payload['grade'] = grade;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId');

    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to update child'));
  }

  /// DELETE /api/v1/children/{childId}
  static Future<void> deleteChild(String childId) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId');

    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to delete child'));
  }

  // ── Absence sub-resource ──────────────────────────────────────────────────

  /// GET /api/v1/children/{childId}/absences
  static Future<List<Map<String, dynamic>>> getChildAbsences(String childId) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId/absences');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = decoded is Map ? decoded['data'] : decoded;
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
      return [];
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load absences'));
  }

  /// POST /api/v1/children/{childId}/absences
  /// absenceType: "MORNING" | "EVENING" | "MULTIPLE_DAYS"
  static Future<Map<String, dynamic>> createAbsence({
    required String childId,
    required String absenceType,
    required String startDate,
    String? endDate,
    required int parentId,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId/absences');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'parentId': parentId,
        'absenceType': absenceType,
        'startDate': startDate,
        'endDate': endDate ?? startDate,
      }),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = decoded is Map && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) return data;
      return {};
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to create absence'));
  }

  /// PUT /api/v1/children/{childId}/absences/{absenceId}
  static Future<Map<String, dynamic>> updateAbsence({
    required String childId,
    required int absenceId,
    required String absenceType,
    required String startDate,
    required String endDate,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/absences/$absenceId',
    );

    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'absenceType': absenceType,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'ACTIVE',
      }),
    );

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = decoded is Map && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) return data;
      return {};
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to update absence'));
  }

  /// DELETE /api/v1/children/{childId}/absences/{absenceId}
  static Future<void> deleteAbsence({
    required String childId,
    required int absenceId,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/absences/$absenceId',
    );

    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) return;

    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to cancel absence'));
  }

  // ── Child photo ────────────────────────────────────────────────────────────

  /// PATCH /api/v1/children/{childId}/photo  (multipart)
  static Future<void> uploadChildPhoto({
    required String childId,
    required File imageFile,
  }) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId/photo');

    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'png' : 'jpeg';

    final req = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', mime),
      ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) return;

    final decoded = _decodeBody(res.body);
    throw Exception(_extractErrorMessage(decoded, 'Failed to upload photo'));
  }

  /// GET /api/v1/children/{childId}/photo  → raw bytes
  static Future<Uint8List?> getChildPhotoBytes(String childId) async {
    final token = await _requireToken();

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/children/$childId/photo');

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) return res.bodyBytes;
    return null; // 404 = no photo set
  }
}