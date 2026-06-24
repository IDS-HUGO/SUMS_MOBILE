import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/vacunacion_repository.dart';
import '../datasources/remote/vacunacion_remote_datasource.dart';

import '../../../cedula_orquestador/domain/repositories/cedula_repository.dart';

class VacunacionRepositoryImpl implements VacunacionRepository {
  final VacunacionRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final CedulaRepository cedulaRepository;

  const VacunacionRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.cedulaRepository,
  });

  @override
  Future<List<String>> getVacunasOpts() async {
    final items = await cedulaRepository.getCatalog('vacunas');
    return items.map((e) => e.nombre).toList();
  }

  @override
  Future<List<String>> getDosisOpts() async {
    final items = await cedulaRepository.getCatalog('dosis');
    return items.map((e) => e.nombre).toList();
  }
}
