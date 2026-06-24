import '../../../../core/storage/token_storage.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../../domain/repositories/vivienda_repository.dart';
import '../datasources/remote/vivienda_remote_datasource.dart';

class ViviendaRepositoryImpl implements ViviendaRepository {
  final ViviendaRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const ViviendaRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    final token = await tokenStorage.readToken();
    final response = await remoteDataSource.getCatalog(key, token: token);
    return response
        .whereType<Map<String, dynamic>>()
        .map(CatalogItem.fromJson)
        .toList();
  }
}
