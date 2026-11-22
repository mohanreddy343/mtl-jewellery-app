/// One place for every API address and setting.
///
/// Development (USB tunnel):  flutter run
/// Production build:          flutter build apk --release \
///                              --dart-define=API_BASE_URL=https://api.yourdomain.com
class ApiConfig {
  // Set to true when you ship, or pass --dart-define=API_BASE_URL=...
  static const bool isProduction = false;

  // Development address. USB tunnel: http://localhost:3000
  // Wi-Fi: your laptop IPv4, e.g. http://10.122.245.1:3000
  // Android emulator: http://10.0.2.2:3000
  static const String devBaseUrl = 'http://10.86.148.1:3000';

  // Production address (must be https)
  static const String prodBaseUrl = 'https://api.yourdomain.com';

  // --dart-define=API_BASE_URL=... overrides both when given
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String baseUrl = _override != ''
      ? _override
      : (isProduction ? prodBaseUrl : devBaseUrl);

  static const Duration timeout = Duration(seconds: 15);
}