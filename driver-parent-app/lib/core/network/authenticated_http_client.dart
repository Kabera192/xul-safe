import 'dart:io';

import 'package:http/http.dart' as http;

import '../../main.dart';
import '../auth/auth_service.dart';
import '../session/session_storage.dart';

typedef AuthenticatedRequestBuilder =
    Future<http.BaseRequest> Function();

class AuthenticatedHttpClient {
  AuthenticatedHttpClient._();

  static Future<http.Response> send(
    AuthenticatedRequestBuilder requestBuilder,
  ) async {
    return _send(
      requestBuilder,
      canRetry: true,
    );
  }

  static Future<http.Response> _send(
    AuthenticatedRequestBuilder requestBuilder, {
    required bool canRetry,
  }) async {
    final token = await SessionStorage.getToken();

    if (token == null || token.isEmpty) {
      await logoutAndReturnToLogin();

      throw Exception('No session token found');
    }

    final request = await requestBuilder();

    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 401) {
      return response;
    }

    if (!canRetry) {
      await logoutAndReturnToLogin();
      return response;
    }

    final refreshed = await AuthService.refreshSession();

    if (!refreshed) {
      await logoutAndReturnToLogin();
      return response;
    }

    return _send(
      requestBuilder,
      canRetry: false,
    );
  }
}