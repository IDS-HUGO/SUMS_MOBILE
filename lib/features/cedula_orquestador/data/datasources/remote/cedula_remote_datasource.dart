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

  Future<Map<String, dynamic>> getAllCedulas({String? token, int page = 1, int limit = 50, String search = ''}) {
    final query = '?page=$page&limit=$limit&search=${Uri.encodeQueryComponent(search)}';
    return apiClient.get('/cedulas$query', token: token);
  }

  Future<Map<String, dynamic>> postCapturaCompleta(
    Map<String, dynamic> body, {
    String? token,
  }) {
    return apiClient.post(
      '/cedulas/captura-completa',
      body: body,
      token: token,
    );
  }

  Future<dynamic> postSync(List<Map<String, dynamic>> body, {String? token}) {
    return apiClient.post('/sums/sync', body: {'payloads': body}, token: token);
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
