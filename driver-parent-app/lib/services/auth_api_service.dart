import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../features/auth/models/auth_result_model.dart';

/// Login/registration API calls. Not to be confused with
/// `core/auth/auth_service.dart`'s `AuthService`, which handles
/// refreshing an already-issued session token.
class AuthApiService {
  static Future<AuthResultModel> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');

    http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier.trim(),
          'password': password,
        }),
      );
    } catch (_) {
      throw Exception('Could not reach server. Check your connection.');
    }

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      return AuthResultModel.fromApiResponse(decoded);
    }

    throw Exception(_extractErrorMessage(decoded, 'Invalid credentials'));
  }

  /// Creates the account in an unverified state and sends an OTP to
  /// [email]. No tokens are issued yet — the account only becomes usable
  /// once [verifyRegistrationOtp] succeeds.
  static Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register');

    http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'phoneNumber': phoneNumber.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );
    } catch (_) {
      throw Exception('Could not reach server. Check your connection.');
    }

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    }

    throw Exception(_extractErrorMessage(decoded, 'Registration failed'));
  }

  /// Confirms the registration OTP and activates the account. Issues
  /// tokens on success, same shape as [login].
  static Future<AuthResultModel> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/verify-registration');

    http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'otp': otp.trim()}),
      );
    } catch (_) {
      throw Exception('Could not reach server. Check your connection.');
    }

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      return AuthResultModel.fromApiResponse(decoded);
    }

    throw Exception(_extractErrorMessage(decoded, 'Invalid or expired code'));
  }

  /// Resends the registration OTP for an unverified account.
  static Future<void> resendRegistrationOtp({required String email}) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/resend-registration-otp');

    http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );
    } catch (_) {
      throw Exception('Could not reach server. Check your connection.');
    }

    final decoded = _decodeBody(res.body);

    if (res.statusCode == 200) {
      return;
    }

    throw Exception(_extractErrorMessage(decoded, 'Failed to resend code'));
  }

  static dynamic _decodeBody(String body) {
    final trimmed = body.trim();
    return trimmed.isNotEmpty ? jsonDecode(trimmed) : null;
  }

  static String _extractErrorMessage(dynamic decoded, String fallback) {
    if (decoded is Map<String, dynamic>) {
      final serverMessage = decoded['message']?.toString();
      final serverError = decoded['error']?.toString();

      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }
      if (serverError != null && serverError.isNotEmpty) {
        return serverError;
      }
    }

    return fallback;
  }
}
