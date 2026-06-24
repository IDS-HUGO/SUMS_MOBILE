import '../../../../core/storage/token_storage.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../../domain/repositories/familia_repository.dart';
import '../datasources/remote/familia_remote_datasource.dart';

import '../../../cedula_orquestador/domain/repositories/cedula_repository.dart';

class FamiliaRepositoryImpl implements FamiliaRepository {
  final FamiliaRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final CedulaRepository cedulaRepository;

  const FamiliaRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.cedulaRepository,
  });

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    return cedulaRepository.getCatalog(key);
  }
}
