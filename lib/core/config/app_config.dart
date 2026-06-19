class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://shreshtlibrary.onrender.com/api/v1',
  );
}
