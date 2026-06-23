import '../../../../../core/network/api_client.dart';

class VacunacionRemoteDataSource {
  final ApiClient apiClient;

  const VacunacionRemoteDataSource({required this.apiClient});

  Future<List<String>> getCatalog(String key, {String? token}) async {
    final response = await apiClient.getList('/catalogos/$key', token: token);
    return response.map((item) => item.toString()).toList();
  }
}
