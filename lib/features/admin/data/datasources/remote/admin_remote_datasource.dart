import '../../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  const AdminRemoteDataSource({required this.apiClient});

  // Usuarios
  Future<List<dynamic>> getUsers({String? token}) async {
    return apiClient.getList('/users', token: token);
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body, {String? token}) async {
    // Para roles que no sean entrevistador, usamos admin/register.
    // Opcionalmente podemos usar /register-entrevistador si es necesario.
    // Asumiremos /users/admin/register como dijo el subagente.
    return apiClient.post('/users/admin/register', body: body, token: token);
  }

  // Unidades de Salud
  Future<List<dynamic>> getUnidadesSalud({String? token}) async {
    return apiClient.getList('/unidadSalud', token: token);
  }

  Future<Map<String, dynamic>> createUnidadSalud(Map<String, dynamic> body, {String? token}) async {
    return apiClient.post('/unidadSalud', body: body, token: token);
  }

  // Catálogos
  Future<List<dynamic>> getCatalog(String key, {String? token}) async {
    return apiClient.getList('/catalogos/$key', token: token);
  }

  Future<Map<String, dynamic>> createCatalogItem(String catalogName, Map<String, dynamic> body, {String? token}) async {
    // La API Node no tiene esto aún, pero la crearemos.
    return apiClient.post('/catalogos/$catalogName', body: body, token: token);
  }
}
