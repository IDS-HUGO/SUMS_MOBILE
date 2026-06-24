import '../../../../../core/network/api_client.dart';

class FamiliaRemoteDataSource {
  final ApiClient apiClient;

  const FamiliaRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> getCatalog(String key, {String? token}) {
    return apiClient.getList('/catalogos/$key', token: token);
  }
}
