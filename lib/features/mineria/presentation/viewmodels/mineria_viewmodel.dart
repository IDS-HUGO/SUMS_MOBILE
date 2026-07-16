import 'package:flutter/foundation.dart';
import '../../domain/entities/mineria_result.dart';
import '../../domain/entities/riesgo_familiar.dart';
import '../../domain/repositories/mineria_repository.dart';

enum MineriaState { initial, loading, success, error }

class MineriaViewModel extends ChangeNotifier {
  final MineriaRepository repository;

  MineriaViewModel({required this.repository});

  // ESTADO
  MineriaState _state = MineriaState.initial;
  String? _errorMessage;
  List<MineriaResult> _searchResults = [];
  List<RiesgoFamiliar> _riesgoList = [];

  // GETTERS
  MineriaState get state => _state;
  String? get errorMessage => _errorMessage;
  List<MineriaResult> get searchResults => _searchResults;
  List<RiesgoFamiliar> get riesgoList => _riesgoList;

  bool get isLoading => _state == MineriaState.loading;
  bool get hasError => _state == MineriaState.error;
  bool get isSuccess => _state == MineriaState.success;

  /// Busca casos usando procesamiento de lenguaje natural.
  Future<void> buscar(String query) async {
    if (query.trim().isEmpty) return;
    
    _setLoading();
    try {
      _searchResults = await repository.buscarCasos(query);
      _state = MineriaState.success;
    } catch (e) {
      _setError(e.toString());
    }
    notifyListeners();
  }

  /// Carga la lista de riesgo familiar desde el microservicio.
  Future<void> loadRiesgo() async {
    _setLoading();
    try {
      _riesgoList = await repository.getRiesgoLista();
      _state = MineriaState.success;
    } catch (e) {
      _setError(e.toString());
    }
    notifyListeners();
  }

  // HELPERS
  void _setLoading() {
    _state = MineriaState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = MineriaState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _state = MineriaState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
