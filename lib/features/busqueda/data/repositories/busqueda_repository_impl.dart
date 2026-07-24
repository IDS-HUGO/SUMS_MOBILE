import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/busqueda_repository.dart';
import '../datasources/remote/busqueda_remote_datasource.dart';

class BusquedaRepositoryImpl implements BusquedaRepository {
  final BusquedaRemoteDataSource remoteDataSource;

  const BusquedaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RespuestaBusqueda> buscar(
    String consulta, {
    String motor = 'bm25',
    int k = 5,
  }) {
    return remoteDataSource.buscar(consulta, motor: motor, k: k);
  }

  @override
  Future<RespuestaBusquedaEstructurada> buscarEstructurado(
    String consulta, {
    int k = 20,
  }) {
    return remoteDataSource.buscarEstructurado(consulta, k: k);
  }
}
