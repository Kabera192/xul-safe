import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../session/session_storage.dart';

class AuthService {
  AuthService._();

  static Future<bool>? _refreshFuture;

  static Future<bool> refreshSession() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  static Future<bool> _performRefresh() async {
    final refreshToken = await SessionStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/refresh'),
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final user = decoded['user'];

      if (user is! Map<String, dynamic>) {
        return false;
      }

      final roles = user['roles'];

      String role = 'PARENT';

      if (roles is List && roles.isNotEmpty) {
        role = roles.first.toString();
      }

      final userIdRaw = user['user_id'];

      final int userId = userIdRaw is int
          ? userIdRaw
          : int.tryParse(userIdRaw.toString()) ?? 0;

      await SessionStorage.saveSession(
        token: decoded['token']?.toString() ?? '',
        refreshToken: decoded['refresh_token']?.toString() ?? '',
        tokenExpiresAt: decoded['token_expires_at']?.toString() ?? '',
        refreshTokenExpiresAt:
            decoded['refresh_token_expires_at']?.toString() ?? '',
        userId: userId,
        role: role,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}