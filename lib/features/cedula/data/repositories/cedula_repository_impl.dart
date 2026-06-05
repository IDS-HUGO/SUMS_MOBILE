import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/cedula_repository.dart';
import '../datasources/remote/cedula_remote_datasource.dart';

class CedulaRepositoryImpl implements CedulaRepository {
  final CedulaRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const CedulaRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<String>> getCatalogKeys() async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.getCatalogKeys(token: token);
  }

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    final token = await tokenStorage.readToken();
    final response = await remoteDataSource.getCatalog(key, token: token);
    return response
        .whereType<Map<String, dynamic>>()
        .map(CatalogItem.fromJson)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createRecord(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.post(path, body, token: token);
  }

  @override
  Future<Map<String, dynamic>> patchRecord(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.patch(path, body, token: token);
  }
}
