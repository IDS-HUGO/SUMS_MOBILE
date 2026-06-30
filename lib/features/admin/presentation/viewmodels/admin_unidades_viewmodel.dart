import 'package:flutter/foundation.dart';
import '../../domain/entities/unidad_salud_entity.dart';
import '../../domain/repositories/admin_repository.dart';

enum AdminUnidadesStatus { initial, loading, loaded, error }

class AdminUnidadesViewModel extends ChangeNotifier {
  final AdminRepository repository;

  AdminUnidadesViewModel({required this.repository});

  AdminUnidadesStatus _status = AdminUnidadesStatus.initial;
  List<UnidadSaludEntity> _unidades = [];
  String? _errorMessage;

  AdminUnidadesStatus get status => _status;
  List<UnidadSaludEntity> get unidades => _unidades;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUnidades() async {
    _status = AdminUnidadesStatus.loading;
    notifyListeners();

    try {
      _unidades = await repository.getUnidadesSalud();
      _status = AdminUnidadesStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = AdminUnidadesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createUnidad(Map<String, dynamic> body) async {
    _status = AdminUnidadesStatus.loading;
    notifyListeners();

    try {
      final nuevaUnidad = await repository.createUnidadSalud(body);
      _unidades.add(nuevaUnidad);
      _status = AdminUnidadesStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AdminUnidadesStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
