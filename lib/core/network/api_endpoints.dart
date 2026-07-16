class ApiEndpoints {
  /// URL de producción. Cambiar a http://localhost:3000 para desarrollo local.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sums-api.troy.engineer/sums',
  );

  /// Motor de Minería (Python)
  /// En emulador Android usar http://10.0.2.2:8001
  static const mineriaBaseUrl = String.fromEnvironment(
    'MINERIA_BASE_URL',
    defaultValue: 'http://10.0.2.2:8001',
  );
}