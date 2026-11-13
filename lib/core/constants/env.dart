/// Environment configuration for the RetailOS mobile app.
///
/// Values can be overridden at build time via `--dart-define`:
///   flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
///
/// The CI workflow (.github/workflows/build-mobile.yml) automatically passes
/// the production backend URL via --dart-define when building release APK/AAB.
class Env {
  Env._();

  /// Base URL of the RetailOS backend API.
  ///
  /// Default points to the production Render deployment. Override at build time
  /// with --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1 for local dev
  /// on the Android emulator (10.0.2.2 = host machine).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://retailos-backend-v3lw.onrender.com/api/v1',
  );

  /// Web app base URL (for invitation links).
  static const String webappBaseUrl = String.fromEnvironment(
    'WEBAPP_BASE_URL',
    defaultValue: 'https://retailos-web.onrender.com',
  );

  /// App environment: 'dev' | 'staging' | 'prod'
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  static bool get isProd => environment == 'prod';
  static bool get isDev => environment == 'dev';

  /// App version (matches pubspec version).
  static const String appVersion = '1.0.0';
}
