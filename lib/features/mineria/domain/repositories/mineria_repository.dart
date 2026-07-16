import '../entities/mineria_result.dart';
import '../entities/riesgo_familiar.dart';

abstract class MineriaRepository {
  Future<List<MineriaResult>> buscarCasos(String query);
  Future<List<RiesgoFamiliar>> getRiesgoLista();
}
