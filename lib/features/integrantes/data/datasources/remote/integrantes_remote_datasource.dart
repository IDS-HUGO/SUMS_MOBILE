import '../../../../../core/network/api_client.dart';

class IntegrantesRemoteDataSource {
  final ApiClient apiClient;

  const IntegrantesRemoteDataSource({required this.apiClient});

  Future<List<String>> getCatalog(String key, {String? token}) async {
    final response = await apiClient.getList('/catalogos/$key', token: token);
    return response.map((item) => item.toString()).toList();
  }
}
