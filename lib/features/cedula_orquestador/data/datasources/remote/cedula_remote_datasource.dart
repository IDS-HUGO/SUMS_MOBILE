import '../../../../../core/network/api_client.dart';

class CedulaRemoteDataSource {
  final ApiClient apiClient;

  const CedulaRemoteDataSource({required this.apiClient});

  // ── Catálogos ──────────────────────────────────────────────────────────────

  /// Lista los nombres de catálogos disponibles.
  Future<List<String>> getCatalogKeys({String? token}) async {
    final response = await apiClient.getList('/catalogos', token: token);
    return response.map((item) => item.toString()).toList();
  }

  /// Obtiene los items de un catálogo específico.
  Future<List<dynamic>> getCatalog(String key, {String? token}) {
    return apiClient.getList('/catalogos/$key', token: token);
  }

  // ── Captura completa (endpoint principal) ──────────────────────────────────

  /// POST /cedulas/captura-completa
  /// Envía toda la cédula en un solo request. El backend maneja todas las
  /// inserciones en cascada (nucleo → direccion → vivienda → personas → vacunas).
  Future<Map<String, dynamic>> postCapturaCompleta(
    Map<String, dynamic> body, {
    String? token,
  }) {
    return apiClient.post('/cedulas/captura-completa', body: body, token: token);
  }

  // ── Métodos genéricos (para flujos paso a paso si se necesitan) ────────────

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return apiClient.post(path, body: body, token: token);
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return apiClient.patch(path, body: body, token: token);
  }
}
