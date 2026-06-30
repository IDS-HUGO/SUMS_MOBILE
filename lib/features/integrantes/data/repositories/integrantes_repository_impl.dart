import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/integrantes_repository.dart';
import '../datasources/remote/integrantes_remote_datasource.dart';

import '../../../cedula_orquestador/domain/repositories/cedula_repository.dart';

class IntegrantesRepositoryImpl implements IntegrantesRepository {
  final IntegrantesRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final CedulaRepository cedulaRepository;

  const IntegrantesRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.cedulaRepository,
  });

  @override
  Future<List<String>> getCatalogOpts(String key) async {
    final items = await cedulaRepository.getCatalog(key);
    return items.map((e) => e.nombre).toList();
  }
}
