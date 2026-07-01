class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Local ASP.NET Core Web API (New Framework). Use 10.0.2.2 for Android Emulator.
    defaultValue: 'https://shreshtlibrary.onrender.com/api/v1',
  );
}
