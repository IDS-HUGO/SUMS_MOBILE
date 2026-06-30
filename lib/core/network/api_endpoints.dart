class ApiEndpoints {
  /// URL de producción. Cambiar a http://localhost:3000 para desarrollo local.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-sums.troy.engineer/sums',
  );
}