import '../../../../core/storage/token_storage.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../../domain/repositories/familia_repository.dart';
import '../datasources/remote/familia_remote_datasource.dart';

class FamiliaRepositoryImpl implements FamiliaRepository {
  final FamiliaRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const FamiliaRepositoryImpl({
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
