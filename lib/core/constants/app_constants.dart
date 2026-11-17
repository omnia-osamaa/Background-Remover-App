class AppConstants {
  AppConstants._();

  static const String appName = 'Background Remover';
  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Local storage keys
  static const String themeModeKey = 'theme_mode';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String authTokenKey = 'auth_token';
}
