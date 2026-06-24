import '../../../../core/storage/token_storage.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../../domain/repositories/vivienda_repository.dart';
import '../datasources/remote/vivienda_remote_datasource.dart';

import '../../../cedula_orquestador/domain/repositories/cedula_repository.dart';

class ViviendaRepositoryImpl implements ViviendaRepository {
  final ViviendaRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final CedulaRepository cedulaRepository;

  const ViviendaRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.cedulaRepository,
  });

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    return cedulaRepository.getCatalog(key);
  }
}
