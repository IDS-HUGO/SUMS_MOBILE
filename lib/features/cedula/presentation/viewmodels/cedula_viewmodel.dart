import 'package:flutter/foundation.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/usecases/load_catalogs_usecase.dart';
import '../../domain/usecases/submit_record_usecase.dart';

enum CedulaStatus { initial, loading, success, error }

class CedulaViewModel extends ChangeNotifier {
  final LoadCatalogsUseCase loadCatalogsUseCase;
  final SubmitRecordUseCase submitRecordUseCase;

  CedulaViewModel({
    required this.loadCatalogsUseCase,
    required this.submitRecordUseCase,
  });

  CedulaStatus _status = CedulaStatus.initial;
  String? _errorMessage;
  String? _successMessage;
  Map<String, List<CatalogItem>> _catalogs = {};

  int? lastNucleoId;
  int? lastPersonaId;
  int? lastCedulaId;
  int? lastViviendaId;

  CedulaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _status == CedulaStatus.loading;
  Map<String, List<CatalogItem>> get catalogs => _catalogs;

  Future<void> loadCatalogs() async {
    _setLoading();
    try {
      _catalogs = await loadCatalogsUseCase();
      _status = CedulaStatus.success;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  Future<bool> submit({
    required String path,
    required Map<String, dynamic> body,
    required String successMessage,
    String? captureIdAs,
    bool patch = false,
  }) async {
    _setLoading();
    try {
      final response = await submitRecordUseCase(path, _clean(body), patch: patch);
      final capturedId = _readId(response);
      if (captureIdAs != null && capturedId != null) {
        _storeLastId(captureIdAs, capturedId);
      }
      _status = CedulaStatus.success;
      _successMessage = capturedId == null
          ? successMessage
          : '$successMessage ID: $capturedId';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    if (_status == CedulaStatus.error) {
      _status = CedulaStatus.initial;
    }
    notifyListeners();
  }

  Map<String, dynamic> _clean(Map<String, dynamic> body) {
    final cleaned = <String, dynamic>{};
    for (final entry in body.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      cleaned[entry.key] = value is String ? value.trim() : value;
    }
    return cleaned;
  }

  int? _readId(Map<String, dynamic> response) {
    final value = response['id'] ??
        response['id_persona'] ??
        response['id_nucleo_familiar'] ??
        response['id_cedula'] ??
        response['id_vivienda'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  void _storeLastId(String key, int value) {
    switch (key) {
      case 'nucleo':
        lastNucleoId = value;
        break;
      case 'persona':
        lastPersonaId = value;
        break;
      case 'cedula':
        lastCedulaId = value;
        break;
      case 'vivienda':
        lastViviendaId = value;
        break;
    }
  }

  void _setLoading() {
    _status = CedulaStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status = CedulaStatus.error;
    _errorMessage = error.toString();
    _successMessage = null;
    notifyListeners();
  }
}
