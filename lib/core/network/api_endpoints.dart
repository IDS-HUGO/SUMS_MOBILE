class ApiEndpoints {
  /// URL de producción. Cambiar a http://localhost:3000 para desarrollo local.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sums-api.troy.engineer/sums',
  );

  /// URL del microservicio de Minería OCR.
  /// En emulador Android usar http://10.0.2.2:8001
  /// En iOS o Web usar http://localhost:8001
  static const mineriaBaseUrl = String.fromEnvironment(
    'MINERIA_API_BASE_URL',
    defaultValue: 'http://192.168.100.6:8001',
  );

  /// API Key para el microservicio de Minería.
  static const mineriaApiKey = String.fromEnvironment(
    'MINERIA_API_KEY',
    defaultValue: 'tu_clave_secreta_aqui',
  );
}
