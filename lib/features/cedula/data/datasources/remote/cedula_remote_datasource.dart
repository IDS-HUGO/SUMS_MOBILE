import '../../../../../core/network/api_client.dart';

class CedulaRemoteDataSource {
  final ApiClient apiClient;

  const CedulaRemoteDataSource({required this.apiClient});

  Future<List<String>> getCatalogKeys({String? token}) async {
    final response = await apiClient.getList('/catalogos', token: token);
    return response.map((item) => item.toString()).toList();
  }

  Future<List<dynamic>> getCatalog(String key, {String? token}) {
    return apiClient.getList('/catalogos/$key', token: token);
  }

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
