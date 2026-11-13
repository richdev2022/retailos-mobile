/// Environment configuration for the RetailOS mobile app.
///
/// Values can be overridden at build time via `--dart-define`:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
class Env {
  Env._();

  /// Base URL of the RetailOS backend API.
  /// Default points to localhost:4000 which works for Android emulator
  /// (10.0.2.2 = host machine). For physical devices use the LAN IP or
  /// production domain.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api/v1',
  );

  /// Web app base URL (for invitation links).
  static const String webappBaseUrl = String.fromEnvironment(
    'WEBAPP_BASE_URL',
    defaultValue: 'https://app.retailos.com',
  );

  /// App environment: 'dev' | 'staging' | 'prod'
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static bool get isProd => environment == 'prod';
  static bool get isDev => environment == 'dev';

  /// App version (matches pubspec version).
  static const String appVersion = '1.0.0';
}
