import '../repositories/mineria_repository.dart';

class GetCatalogosUseCase {
  final MineriaRepository repository;
  const GetCatalogosUseCase(this.repository);
  Future<Map<String, List<String>>> call() {
    return repository.getCatalogos();
  }
}
