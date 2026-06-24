import '../../../../../core/network/api_client.dart';

class ViviendaRemoteDataSource {
  final ApiClient apiClient;

  const ViviendaRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> getCatalog(String key, {String? token}) {
    return apiClient.getList('/catalogos/$key', token: token);
  }
}
