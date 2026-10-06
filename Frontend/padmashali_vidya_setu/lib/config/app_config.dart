import 'package:flutter/foundation.dart';

/// Environment-specific settings, supplied at build time with `--dart-define` or
/// `--dart-define-from-file=config/<env>.json`. No secrets or API keys belong here:
/// everything in a Flutter build can be extracted from the app package.
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  /// development | staging | production
  final String environment;

  /// Base URL of the PVS API, without a trailing slash (e.g. https://api.example.org).
  final String apiBaseUrl;

  bool get isDevelopment => environment == 'development';

  static const _environment = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  factory AppConfig.fromEnvironment() =>
      AppConfig(environment: _environment, apiBaseUrl: _apiBaseUrl.isNotEmpty ? _apiBaseUrl : _defaultDevelopmentUrl());

  /// The Android emulator reaches the host machine through 10.0.2.2.
  static String _defaultDevelopmentUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5274';
    return 'http://localhost:5274';
  }
}
