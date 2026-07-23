import '../entities/resultado_busqueda.dart';
import '../repositories/busqueda_repository.dart';

class BuscarEstructuradoUseCase {
  final BusquedaRepository repository;

  const BuscarEstructuradoUseCase(this.repository);

  Future<RespuestaBusquedaEstructurada> call(
    String consulta, {
    int k = 20,
  }) {
    return repository.buscarEstructurado(consulta, k: k);
  }
}
