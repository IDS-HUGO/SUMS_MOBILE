import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/pending_cedula.dart';
import '../../domain/repositories/cedula_repository.dart';
import '../datasources/local/cedula_local_datasource.dart';
import '../datasources/remote/cedula_remote_datasource.dart';

class CedulaRepositoryImpl implements CedulaRepository {
  final CedulaRemoteDataSource remoteDataSource;
  final CedulaLocalDataSource localDataSource;
  final TokenStorage tokenStorage;

  const CedulaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
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

  @override
  Future<List<PendingCedula>> getPendingRecords() {
    return localDataSource.getAll();
  }

  @override
  Future<int> saveLocalRecord(PendingCedula record) {
    if (record.id != null) {
      return localDataSource.update(record);
    }
    return localDataSource.insert(record);
  }

  @override
  Future<void> deleteLocalRecord(int id) async {
    await localDataSource.delete(id);
  }
}
