import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';
import '../features/driver/models/driver_incident_model.dart';

class IncidentService {
  static Future<DriverIncidentModel> createIncident({
    required String type,
    required String description,
    required String journeyImpact,
    required Set<int> affectedBusIds,
    required Set<String> affectedChildIds,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents',
    );

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

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to create incident',
      ),
    );
  }

  static Future<List<DriverIncidentModel>> getMyIncidents() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/me',
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
        throw Exception('Unexpected incidents response');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(DriverIncidentModel.fromApiResponse)
          .toList();
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load incidents',
      ),
    );
  }

  static Future<DriverIncidentModel> updateIncident({
    required int incidentId,
    String? description,
    String? journeyImpact,
    Set<int>? affectedBusIds,
    Set<String>? affectedChildIds,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/incidents/$incidentId',
    );

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

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to update incident',
      ),
    );
  }

  static Future<DriverIncidentModel> resolveIncident(
    int incidentId,
  ) async {
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
      _extractErrorMessage(
        decoded,
        'Failed to resolve incident',
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

  static dynamic _extractData(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }

    return decoded;
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
}