import '../entities/resumen_estadisticas.dart';
import '../entities/productividad_entrevistador.dart';

abstract class EstadisticasRepository {
  Future<ResumenEstadisticas> getMisCedulasResumen();
  Future<List<ProductividadEntrevistador>> getProductividadEntrevistadores();
}
