import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/estadisticas_endpoints.dart';

class EstadisticasRemoteDataSource {
  final ApiClient apiClient;

  const EstadisticasRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> getMisCedulasResumen({String? token}) async {
    return apiClient.get(EstadisticasEndpoints.misCedulasResumen, token: token);
  }

  Future<List<dynamic>> getProductividadEntrevistadores({String? token}) async {
    return apiClient.getList(EstadisticasEndpoints.productividadEntrevistadores, token: token);
  }
}
