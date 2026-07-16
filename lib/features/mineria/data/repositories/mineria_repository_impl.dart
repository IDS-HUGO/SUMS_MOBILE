import '../../domain/entities/mineria_result.dart';
import '../../domain/entities/riesgo_familiar.dart';
import '../../domain/repositories/mineria_repository.dart';
import '../datasources/remote/mineria_remote_datasource.dart';

class MineriaRepositoryImpl implements MineriaRepository {
  final MineriaRemoteDataSource remoteDataSource;

  const MineriaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MineriaResult>> buscarCasos(String query) {
    return remoteDataSource.buscarCasos(query);
  }

  @override
  Future<List<RiesgoFamiliar>> getRiesgoLista() {
    return remoteDataSource.getRiesgoLista();
  }
}
