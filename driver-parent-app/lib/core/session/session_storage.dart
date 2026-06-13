import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyRole = 'role';
  static const _keyIsLoggedIn = 'is_logged_in';

  static const _keyDriverLastTabIndex = 'driver_last_tab_index';
  static const _keyParentLastTabIndex = 'parent_last_tab_index';

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
  // LAST TAB
  // =========================
  static Future<void> saveDriverLastTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDriverLastTabIndex, index);
  }

  static Future<int> getDriverLastTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDriverLastTabIndex) ?? 0;
  }

  static Future<void> saveParentLastTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyParentLastTabIndex, index);
  }

  static Future<int> getParentLastTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyParentLastTabIndex) ?? 0;
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

    await prefs.remove(_keyDriverLastTabIndex);
    await prefs.remove(_keyParentLastTabIndex);

    await prefs.setBool(_keyIsLoggedIn, false);
  }
}