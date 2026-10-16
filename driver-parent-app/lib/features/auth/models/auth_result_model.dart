/// Successful login/register response: session tokens plus the minimal
/// user info needed to route to the right home screen.
class AuthResultModel {
  final String token;
  final String refreshToken;
  final String tokenExpiresAt;
  final String refreshTokenExpiresAt;
  final int userId;
  final String role;

  const AuthResultModel({
    required this.token,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.userId,
    required this.role,
  });

  factory AuthResultModel.fromApiResponse(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }

    final user = decoded['user'];
    if (user is! Map<String, dynamic>) {
      throw Exception('User data missing from response');
    }

    final roles = user['roles'];
    String role = 'PARENT';
    if (roles is List && roles.isNotEmpty) {
      role = roles.first.toString();
    }

    final userIdRaw = user['user_id'];
    final userId =
        userIdRaw is int ? userIdRaw : int.tryParse(userIdRaw.toString()) ?? 0;

    return AuthResultModel(
      token: decoded['token']?.toString() ?? '',
      refreshToken: decoded['refresh_token']?.toString() ?? '',
      tokenExpiresAt: decoded['token_expires_at']?.toString() ?? '',
      refreshTokenExpiresAt:
          decoded['refresh_token_expires_at']?.toString() ?? '',
      userId: userId,
      role: role,
    );
  }
}
