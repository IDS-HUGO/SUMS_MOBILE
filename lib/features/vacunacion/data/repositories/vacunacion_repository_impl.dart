import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/vacunacion_repository.dart';
import '../datasources/remote/vacunacion_remote_datasource.dart';

class VacunacionRepositoryImpl implements VacunacionRepository {
  final VacunacionRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const VacunacionRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<String>> getVacunasOpts() async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.getCatalog('vacunas', token: token);
  }

  @override
  Future<List<String>> getDosisOpts() async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.getCatalog('dosis', token: token);
  }
}
