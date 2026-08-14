import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/authenticated_http_client.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/notifications/me',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      // Backend returns a raw list; some other endpoints return { "data": [...] }
      final list = decoded is Map ? decoded['data'] : decoded;

      if (list is! List) {
        throw Exception('Unexpected notifications response');
      }

      return list.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load notifications',
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/notifications/me/unread',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('GET', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      final list = decoded is Map ? decoded['data'] : decoded;

      if (list is! List) {
        throw Exception('Unexpected unread notifications response');
      }

      return list.whereType<Map<String, dynamic>>().toList();
    }

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to load unread notifications',
      ),
    );
  }

  static Future<void> markAsRead(int notificationId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/notifications/$notificationId/read',
    );

    final res = await AuthenticatedHttpClient.send(() async {
      final request = http.Request('PATCH', uri);
      request.headers['Content-Type'] = 'application/json';

      return request;
    });

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    }

    final decoded = _decodeBody(res.body);

    throw Exception(
      _extractErrorMessage(
        decoded,
        'Failed to mark notification as read',
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
}