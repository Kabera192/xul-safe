import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';
import '../features/driver/models/driver_incident_model.dart';
import '../features/parent/models/parent_incident_model.dart';
import '../features/parent/models/incident_attachment_model.dart';
import 'package:http_parser/http_parser.dart';

class IncidentService {
  static Future<DriverIncidentModel> createIncident({
    required String type,
    required String description,
    required String journeyImpact,
    required Set<int> affectedBusIds,
    required Set<String> affectedChildIds,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/incidents');

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('POST', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'type': type,
        'description': description.trim(),
        'journeyImpact': journeyImpact,
        'affectedBusIds': affectedBusIds.toList(),
        'affectedChildIds': affectedChildIds.toList(),
      });

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = _extractData(decoded);

      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected create incident response');
      }

      return DriverIncidentModel.fromApiResponse(data);
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to create incident'));
  }

  static Future<void> addAttachment({
    required int incidentId,
    required File file,
    required String type,
  }) async {
    final normalizedType = type.trim().toUpperCase();

    if (normalizedType != 'IMAGE' && normalizedType != 'AUDIO') {
      throw Exception('Unsupported incident attachment type');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/$incidentId/attachments',
    );

    final MediaType contentType;

    if (normalizedType == 'IMAGE') {
      final ext = file.path.split('.').last.toLowerCase();

      contentType = switch (ext) {
        'png' => MediaType('image', 'png'),
        'webp' => MediaType('image', 'webp'),
        _ => MediaType('image', 'jpeg'),
      };
    } else {
      // BussApp voice notes are recorded as AAC audio
      // in an M4A/MP4 container.
      contentType = MediaType('audio', 'mp4');
    }

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.MultipartRequest('POST', uri);

      request.fields['type'] = normalizedType;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: contentType,
        ),
      );

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to upload incident attachment'),
    );
  }

  static Future<List<DriverIncidentModel>> getMyIncidents() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/incidents/me');

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = _extractData(decoded);

      if (data is! List) {
        throw Exception('Unexpected incidents response');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(DriverIncidentModel.fromApiResponse)
          .toList();
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to load incidents'));
  }

  static Future<List<ParentIncidentModel>> getParentIncidents() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/incidents/parent/me');

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = _extractData(decoded);

      if (data is! List) {
        throw Exception('Unexpected parent incidents response');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(ParentIncidentModel.fromJson)
          .toList();
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to load parent incidents'),
    );
  }

  static Future<List<IncidentAttachmentModel>> getAttachments(
    int incidentId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/$incidentId/attachments',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = _extractData(decoded);

      if (data is! List) {
        throw Exception('Unexpected incident attachments response');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(IncidentAttachmentModel.fromJson)
          .toList();
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to load incident attachments'),
    );
  }

  static Future<List<int>> getAttachmentBytes({
    required int incidentId,
    required int attachmentId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/'
      '$incidentId/attachments/$attachmentId',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);

      return request;
    });

    if (res.statusCode == 200) {
      return res.bodyBytes;
    }

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to load incident attachment'),
    );
  }

  static Future<DriverIncidentModel> updateIncident({
    required int incidentId,
    String? description,
    String? journeyImpact,
    Set<int>? affectedBusIds,
    Set<String>? affectedChildIds,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/incidents/$incidentId');

    final payload = <String, dynamic>{};

    if (description != null) {
      payload['description'] = description.trim();
    }

    if (journeyImpact != null) {
      payload['journeyImpact'] = journeyImpact;
    }

    if (affectedBusIds != null) {
      payload['affectedBusIds'] = affectedBusIds.toList();
    }

    if (affectedChildIds != null) {
      payload['affectedChildIds'] = affectedChildIds.toList();
    }

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('PATCH', uri);

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(payload);

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = _extractData(decoded);

      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected update incident response');
      }

      return DriverIncidentModel.fromApiResponse(data);
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to update incident'));
  }

  static Future<DriverIncidentModel> resolveIncident(int incidentId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/$incidentId/resolve',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('PATCH', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final data = _extractData(decoded);

      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected resolve incident response');
      }

      return DriverIncidentModel.fromApiResponse(data);
    }

    throw Exception(
      _extractErrorMessage(decoded, 'Failed to resolve incident'),
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

  static dynamic _extractData(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }

    return decoded;
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
