import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyRole = 'role';
  static const _keyIsLoggedIn = 'is_logged_in';

  // =========================
  // SAVE SESSION
  // =========================
  static Future<void> saveSession({
    required String token,
    required String refreshToken,
    required int userId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // =========================
  // GETTERS
  // =========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // =========================
  // CLEAR SESSION (LOGOUT)
  // =========================
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}