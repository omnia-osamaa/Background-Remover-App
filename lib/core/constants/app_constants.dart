class AppConstants {
  AppConstants._();

  static const String appName = 'Background Remover';
  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Real background removal (remove.bg). Leave empty to use the fake data source.
  // Run with: flutter run --dart-define=REMOVE_BG_API_KEY=your_key
  static const String removeBgApiKey =
      String.fromEnvironment('REMOVE_BG_API_KEY');
  static const String removeBgUrl = 'https://api.remove.bg/v1.0/removebg';

  // Local storage keys
  static const String themeModeKey = 'theme_mode';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String authTokenKey = 'auth_token';
  static const String userKey = 'cached_user';
  static const String planIdKey = 'current_plan_id';
  static const String usageDateKey = 'usage_date';
  static const String usageCountKey = 'usage_count';
  static const String historyKey = 'history_items';
}
