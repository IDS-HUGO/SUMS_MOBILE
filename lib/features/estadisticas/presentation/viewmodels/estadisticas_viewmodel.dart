import 'package:flutter/foundation.dart';
import '../../domain/entities/resumen_estadisticas.dart';
import '../../domain/entities/productividad_entrevistador.dart';
import '../../domain/repositories/estadisticas_repository.dart';

enum EstadisticasStatus { initial, loading, loaded, error }

class EstadisticasViewModel extends ChangeNotifier {
  final EstadisticasRepository repository;

  EstadisticasViewModel({required this.repository});

  EstadisticasStatus _resumenStatus = EstadisticasStatus.initial;
  ResumenEstadisticas? _resumen;
  String? _resumenError;

  EstadisticasStatus _productividadStatus = EstadisticasStatus.initial;
  List<ProductividadEntrevistador> _productividad = [];
  String? _productividadError;

  // Getters Resumen
  EstadisticasStatus get resumenStatus => _resumenStatus;
  ResumenEstadisticas? get resumen => _resumen;
  String? get resumenError => _resumenError;
  bool get isResumenLoading => _resumenStatus == EstadisticasStatus.loading;

  // Getters Productividad
  EstadisticasStatus get productividadStatus => _productividadStatus;
  List<ProductividadEntrevistador> get productividad => _productividad;
  String? get productividadError => _productividadError;
  bool get isProductividadLoading => _productividadStatus == EstadisticasStatus.loading;

  Future<void> fetchResumen() async {
    _resumenStatus = EstadisticasStatus.loading;
    _resumenError = null;
    notifyListeners();

    try {
      _resumen = await repository.getMisCedulasResumen();
      _resumenStatus = EstadisticasStatus.loaded;
    } catch (e) {
      _resumenStatus = EstadisticasStatus.error;
      _resumenError = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchProductividad() async {
    _productividadStatus = EstadisticasStatus.loading;
    _productividadError = null;
    notifyListeners();

    try {
      _productividad = await repository.getProductividadEntrevistadores();
      _productividadStatus = EstadisticasStatus.loaded;
    } catch (e) {
      _productividadStatus = EstadisticasStatus.error;
      _productividadError = e.toString();
    }
    notifyListeners();
  }

  void clearErrors() {
    _resumenError = null;
    _productividadError = null;
    notifyListeners();
  }
}
