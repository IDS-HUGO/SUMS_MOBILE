import '../../domain/entities/resumen_estadisticas.dart';
import '../../domain/entities/productividad_entrevistador.dart';
import '../../domain/repositories/estadisticas_repository.dart';
import '../datasources/remote/estadisticas_remote_datasource.dart';
import '../../../../core/storage/token_storage.dart';

class EstadisticasRepositoryImpl implements EstadisticasRepository {
  final EstadisticasRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const EstadisticasRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<ResumenEstadisticas> getMisCedulasResumen() async {
    final token = await tokenStorage.readToken();
    final response = await remoteDataSource.getMisCedulasResumen(token: token);
    
    // Si el endpoint devuelve el objeto directamente
    if (response.containsKey('data')) {
      return ResumenEstadisticas.fromJson(response['data'] as Map<String, dynamic>);
    }
    return ResumenEstadisticas.fromJson(response);
  }

  @override
  Future<List<ProductividadEntrevistador>> getProductividadEntrevistadores() async {
    final token = await tokenStorage.readToken();
    final data = await remoteDataSource.getProductividadEntrevistadores(token: token);
    return data.map((json) => ProductividadEntrevistador.fromJson(json as Map<String, dynamic>)).toList();
  }
}
