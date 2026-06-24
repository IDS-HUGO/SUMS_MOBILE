import '../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  const AdminRemoteDataSource({required this.apiClient});

  // Usuarios
  Future<List<dynamic>> getUsers({String? token}) async {
    final response = await apiClient.get('/users', token: token);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body, {String? token}) async {
    // Para roles que no sean entrevistador, usamos admin/register.
    // Opcionalmente podemos usar /register-entrevistador si es necesario.
    // Asumiremos /users/admin/register como dijo el subagente.
    return apiClient.post('/users/admin/register', body, token: token);
  }

  // Unidades de Salud
  Future<List<dynamic>> getUnidadesSalud({String? token}) async {
    final response = await apiClient.get('/unidadSalud', token: token);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> createUnidadSalud(Map<String, dynamic> body, {String? token}) async {
    return apiClient.post('/unidadSalud', body, token: token);
  }

  // Catálogos
  Future<List<dynamic>> getCatalog(String key, {String? token}) async {
    final response = await apiClient.get('/catalogos/$key', token: token);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> createCatalogItem(String catalogName, Map<String, dynamic> body, {String? token}) async {
    // La API Node no tiene esto aún, pero la crearemos.
    return apiClient.post('/catalogos/$catalogName', body, token: token);
  }
}
