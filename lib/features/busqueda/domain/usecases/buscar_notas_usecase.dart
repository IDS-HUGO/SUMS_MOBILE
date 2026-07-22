import '../entities/resultado_busqueda.dart';
import '../repositories/busqueda_repository.dart';

class BuscarNotasUseCase {
  final BusquedaRepository repository;

  const BuscarNotasUseCase(this.repository);

  Future<RespuestaBusqueda> call(
    String consulta, {
    String motor = 'bm25',
    int k = 5,
  }) {
    return repository.buscar(consulta, motor: motor, k: k);
  }
}
