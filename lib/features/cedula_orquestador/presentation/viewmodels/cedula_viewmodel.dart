import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/usecases/load_catalogs_usecase.dart';
import '../../domain/usecases/submit_record_usecase.dart';
import '../../domain/repositories/cedula_repository.dart';

enum CedulaStatus { initial, loading, success, error }

/// Resultado de una captura completa exitosa.
class CapturaCompletaResult {
  final int?   cedulaId;
  final int    nucleoFamiliarId;
  final int?   direccionId;
  final int?   viviendaId;
  final int    integrantesCreados;
  final int    vacunasCreadas;
  final List<String> warnings;

  const CapturaCompletaResult({
    required this.cedulaId,
    required this.nucleoFamiliarId,
    required this.direccionId,
    required this.viviendaId,
    required this.integrantesCreados,
    required this.vacunasCreadas,
    required this.warnings,
  });

  factory CapturaCompletaResult.fromJson(Map<String, dynamic> json) {
    final integrantes = (json['integrantes'] as List?)?.length ?? 0;
    final inmunizaciones = (json['inmunizaciones'] as List?)?.length ?? 0;
    final warnings = (json['warnings'] as List?)
            ?.map((w) => w.toString())
            .toList() ??
        [];
    return CapturaCompletaResult(
      cedulaId:           _asInt(json['cedula_id']),
      nucleoFamiliarId:   _asInt(json['nucleo_familiar_id']) ?? 0,
      direccionId:        _asInt(json['direccion_id']),
      viviendaId:         _asInt(json['vivienda_id']),
      integrantesCreados: integrantes,
      vacunasCreadas:     inmunizaciones,
      warnings:           warnings,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class CedulaViewModel extends ChangeNotifier {
  final LoadCatalogsUseCase loadCatalogsUseCase;
  final SubmitRecordUseCase submitRecordUseCase;

  CedulaViewModel({
    required this.loadCatalogsUseCase,
    required this.submitRecordUseCase,
    required this.cedulaRepository,
  }) {
    refreshSyncCounts();
    _listenConnectivity();
  }

  final CedulaRepository cedulaRepository;

  int _pendingSyncCount = 0;
  int _draftCount = 0;
  List<Map<String, dynamic>> _allLocalRecords = [];
  bool _isSyncing = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  int get pendingSyncCount => _pendingSyncCount;
  int get draftCount => _draftCount;
  List<Map<String, dynamic>> get allLocalRecords => _allLocalRecords;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;

  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = !results.contains(ConnectivityResult.none);
      final wasOffline = !_isOnline;
      _isOnline = online;
      notifyListeners();
      // Si acabamos de recuperar la conexión y hay cédulas pendientes → sincronizar
      if (online && wasOffline && _pendingSyncCount > 0) {
        await syncNow();
      }
    });
    // También verificar el estado inicial de conectividad
    Connectivity().checkConnectivity().then((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> refreshSyncCounts() async {
    _pendingSyncCount = await cedulaRepository.getPendingSyncCount();
    _draftCount = await cedulaRepository.getDraftCount();
    _allLocalRecords = await cedulaRepository.getAllLocalCedulas();
    notifyListeners();
  }

  /// Sincronización manual/automática en foreground
  Future<SyncResult> syncNow() async {
    if (_isSyncing) return const SyncResult(error: 'Ya hay una sincronización en curso');
    _isSyncing = true;
    notifyListeners();
    try {
      final result = await cedulaRepository.syncPendingCedulas();
      await refreshSyncCounts();
      return result;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Reintenta la sincronización de un registro específico
  Future<SyncResult> retrySyncSingle(int localId) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final result = await cedulaRepository.syncSingleCedula(localId);
      await refreshSyncCounts();
      return result;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }


  CedulaStatus _status = CedulaStatus.initial;
  String?      _errorMessage;
  String?      _successMessage;
  Map<String, List<CatalogItem>> _catalogs = {};
  CapturaCompletaResult? _lastResult;

  // ── IDs guardados para referencia ─────────────────────────────────────────
  int? lastNucleoId;
  int? lastPersonaId;
  int? lastCedulaId;
  int? lastViviendaId;

  // ── Getters ───────────────────────────────────────────────────────────────
  CedulaStatus                     get status         => _status;
  String?                          get errorMessage   => _errorMessage;
  String?                          get successMessage => _successMessage;
  bool                             get isLoading      => _status == CedulaStatus.loading;
  Map<String, List<CatalogItem>>   get catalogs       => _catalogs;
  CapturaCompletaResult?           get lastResult     => _lastResult;

  // ── Catálogos ─────────────────────────────────────────────────────────────

  Future<void> loadCatalogs() async {
    _setLoading();
    try {
      _catalogs     = await loadCatalogsUseCase();
      _status       = CedulaStatus.success;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  // ── Captura completa ──────────────────────────────────────────────────────

  /// Envía toda la cédula al endpoint POST /sums/cedulas/captura-completa.
  ///
  /// El [payload] debe seguir la estructura esperada por el backend:
  /// ```json
  /// {
  ///   "familia":    { informante_nombre, domicilio, localidad, manzana, vivienda_referencia, rol_informante },
  ///   "vivienda":   { techo, paredes, piso, cuartos, habitantes, agua_entubada, ... },
  ///   "vacunacion": { se_aplico_vacuna, vacunas: [...] },
  ///   "integrantes":[ { nombre, sexo, fecha_nacimiento|edad, estado_civil, ... } ],
  ///   "unidad_salud_id":  <int|null>,
  ///   "entrevistador_id": <int|null>
  /// }
  /// ```
  Future<bool> submitCapturaCompleta(Map<String, dynamic> payload) async {
    _setLoading();
    try {
      final response = await submitRecordUseCase.submitCompleta(_clean(payload));
      
      // Manejar caso de borrador o fallback offline
      if (response['status'] == 'draft' || response['status'] == 'pending_sync') {
        _status = CedulaStatus.success;
        _errorMessage = null;
        _successMessage = response['warnings']?.first ?? 'Guardado localmente';
        await refreshSyncCounts();
        notifyListeners();
        return true;
      }

      _lastResult = CapturaCompletaResult.fromJson(response);

      // Guardar IDs principales
      lastNucleoId  = _lastResult?.nucleoFamiliarId;
      lastViviendaId = _lastResult?.viviendaId;
      lastCedulaId  = _lastResult?.cedulaId;

      _status = CedulaStatus.success;
      _errorMessage = null;

      final warnings = _lastResult?.warnings ?? [];
      _successMessage = _buildSuccessMessage(_lastResult!, warnings);

      await refreshSyncCounts();
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  /// Guarda explícitamente como borrador local sin intentar enviarlo
  Future<bool> saveDraft(Map<String, dynamic> payload) async {
    _setLoading();
    try {
      final response = await submitRecordUseCase.submitCompleta(_clean(payload), isDraft: true);
      _status = CedulaStatus.success;
      _errorMessage = null;
      _successMessage = response['warnings']?.first ?? 'Guardado como borrador localmente';
      await refreshSyncCounts();
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  String _buildSuccessMessage(CapturaCompletaResult r, List<String> warnings) {
    final buf = StringBuffer('Cédula guardada. ');
    buf.write('Familia #${r.nucleoFamiliarId}. ');
    buf.write('${r.integrantesCreados} integrante(s). ');
    if (r.vacunasCreadas > 0) buf.write('${r.vacunasCreadas} vacuna(s). ');
    if (warnings.isNotEmpty) buf.write('⚠ ${warnings.length} advertencia(s).');
    return buf.toString();
  }

  // ── Submit genérico (flujos secundarios) ──────────────────────────────────

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
    _errorMessage   = null;
    _successMessage = null;
    _lastResult     = null;
    if (_status == CedulaStatus.error) _status = CedulaStatus.initial;
    notifyListeners();
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

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
    final value = response['id']                   ??
        response['id_persona']                     ??
        response['id_nucleo_familiar']             ??
        response['id_cedula']                      ??
        response['id_vivienda'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  void _storeLastId(String key, int value) {
    switch (key) {
      case 'nucleo':   lastNucleoId    = value; break;
      case 'persona':  lastPersonaId   = value; break;
      case 'cedula':   lastCedulaId    = value; break;
      case 'vivienda': lastViviendaId  = value; break;
    }
  }

  void _setLoading() {
    _status         = CedulaStatus.loading;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status         = CedulaStatus.error;
    _errorMessage   = error.toString();
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
