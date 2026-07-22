import '../repositories/mineria_repository.dart';

class PredecirRiesgoUseCase {
  final MineriaRepository repository;
  const PredecirRiesgoUseCase(this.repository);
  Future<Map<String, dynamic>> call(Map<String, dynamic> payload) {
    return repository.predecirRiesgo(payload);
  }
}
