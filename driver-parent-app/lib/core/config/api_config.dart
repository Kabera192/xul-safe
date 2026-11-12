class ApiConfig {
  /// Base URL for the LoginBus Spring Boot backend.
  /// Running on port 8080 (default). Update the IP to match your dev machine —
  /// 'localhost' only works from an emulator or over an adb reverse tunnel,
  /// not from a real device installed over Wi-Fi.
  static const String baseUrl = 'http://172.20.10.3:8080';
}
