import '../repositories/mineria_repository.dart';

class CheckSaludUseCase {
  final MineriaRepository repository;
  const CheckSaludUseCase(this.repository);
  Future<bool> call() {
    return repository.checkSalud();
  }
}
