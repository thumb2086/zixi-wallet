class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zixi-casino-api.onrender.com/api/',
  );
}
