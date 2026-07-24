import '../../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;
  const AdminRemoteDataSource({required this.apiClient});
  Future<List<dynamic>> getCatalogKeys({String? token}) async {
    return apiClient.getList('/catalogos', token: token);
  }

  Future<List<dynamic>> getUsers({String? token}) async {
    return apiClient.getList('/users', token: token);
  }

  Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.post('/users/admin/register', body: body, token: token);
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.put('/users/$id', body: body, token: token);
  }

  Future<List<dynamic>> getUnidadesSalud({String? token}) async {
    return apiClient.getList('/unidadSalud', token: token);
  }

  Future<Map<String, dynamic>> createUnidadSalud(
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.post('/unidadSalud', body: body, token: token);
  }

  Future<Map<String, dynamic>> updateUnidadSalud(
    int id,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.put('/unidadSalud/$id', body: body, token: token);
  }

  Future<Map<String, dynamic>> deleteUnidadSalud(
    int id, {
    String? token,
  }) async {
    return apiClient.delete('/unidadSalud/$id', token: token);
  }

  Future<List<dynamic>> getCatalog(String key, {String? token}) async {
    return apiClient.getList('/catalogos/$key', token: token);
  }

  Future<Map<String, dynamic>> createCatalogItem(
    String catalogName,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.post('/catalogos/$catalogName', body: body, token: token);
  }

  Future<Map<String, dynamic>> updateCatalogItem(
    String catalogName,
    int id,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return apiClient.put('/catalogos/$catalogName/$id', body: body, token: token);
  }

  Future<Map<String, dynamic>> deleteCatalogItem(
    String catalogName,
    int id, {
    String? token,
  }) async {
    return apiClient.delete('/catalogos/$catalogName/$id', token: token);
  }
}
