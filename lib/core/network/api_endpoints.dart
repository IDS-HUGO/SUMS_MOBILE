class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sums-api.troy.engineer/sums',
  );
  static const mineriaBaseUrl = String.fromEnvironment(
    'MINERIA_API_BASE_URL',
    defaultValue: 'https://sums-mineria.troy.engineer',
  );
  static const mineriaApiKey = String.fromEnvironment(
    'MINERIA_API_KEY',
    defaultValue: 'v38LrNis5nouLd6XSbp38V9WtPHP08jvjWO7PJjzN-o',
  );
}
