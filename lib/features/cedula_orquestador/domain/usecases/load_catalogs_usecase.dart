import '../entities/catalog_item.dart';
import '../repositories/cedula_repository.dart';

class LoadCatalogsUseCase {
  final CedulaRepository repository;

  const LoadCatalogsUseCase(this.repository);

  Future<Map<String, List<CatalogItem>>> call() async {
    final keys = await repository.getCatalogKeys();
    final result = <String, List<CatalogItem>>{};
    for (final key in keys) {
      result[key] = await repository.getCatalog(key);
    }
    return result;
  }
}
