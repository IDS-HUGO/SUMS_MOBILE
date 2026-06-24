import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/integrantes_repository.dart';
import '../datasources/remote/integrantes_remote_datasource.dart';

class IntegrantesRepositoryImpl implements IntegrantesRepository {
  final IntegrantesRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const IntegrantesRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<String>> getCatalogOpts(String key) async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.getCatalog(key, token: token);
  }
}
