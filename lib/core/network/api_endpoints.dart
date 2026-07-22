class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sums-api.troy.engineer/sums',
  );
  static const mineriaBaseUrl = String.fromEnvironment(
    'MINERIA_API_BASE_URL',
    defaultValue: 'http://192.168.100.6:8001',
  );
  static const mineriaApiKey = String.fromEnvironment(
    'MINERIA_API_KEY',
    defaultValue: 'tu_clave_secreta_aqui',
  );
}
