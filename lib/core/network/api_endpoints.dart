class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sums-api.troy.engineer/sums',
  );
  static const mineriaBaseUrl = String.fromEnvironment(
    'MINERIA_API_BASE_URL',
    defaultValue: 'http://my-ip:8001',
  );
  static const mineriaApiKey = String.fromEnvironment(
    'MINERIA_API_KEY',
    defaultValue: 'una-clave-larga-y-secreta',
  );
}
