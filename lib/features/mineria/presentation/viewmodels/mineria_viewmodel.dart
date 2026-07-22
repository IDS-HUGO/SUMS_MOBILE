import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/network/app_logger.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/vacuna_aplicada.dart';
import '../../domain/usecases/check_salud_usecase.dart';
import '../../domain/usecases/get_catalogos_usecase.dart';
import '../../domain/usecases/predecir_riesgo_usecase.dart';
import '../../domain/usecases/procesar_pdf_usecase.dart';

enum MineriaStatus { initial, loading, success, error, saving }

class MineriaViewModel extends ChangeNotifier {
  final ProcesarPdfUseCase procesarPdfUseCase;
  final CheckSaludUseCase checkSaludUseCase;
  final GetCatalogosUseCase getCatalogosUseCase;
  final PredecirRiesgoUseCase predecirRiesgoUseCase;
  MineriaViewModel({
    required this.procesarPdfUseCase,
    required this.checkSaludUseCase,
    required this.getCatalogosUseCase,
    required this.predecirRiesgoUseCase,
  });
  static const int maxFileSizeBytes = 20 * 1024 * 1024;
  static const List<int> _pdfMagicBytes = [0x25, 0x50, 0x44, 0x46, 0x2D];
  MineriaStatus _status = MineriaStatus.initial;
  bool _healthOk = false;
  OcrResult? _result;
  String? _errorMessage;
  File? _selectedFile;
  String? _nivelRiesgo;
  double? _probabilidadAlto;
  String? _prioridadVisita;
  String? _motivoPrioridad;

  // Catálogos
  List<String> vacunasOpts = [];
  List<String> dosisOpts = [];
  final List<VacunaAplicada> vacunasSeleccionadas = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<String>> _groupRegistry = {};
  MineriaStatus get status => _status;
  bool get healthOk => _healthOk;
  OcrResult? get result => _result;
  String? get errorMessage => _errorMessage;
  File? get selectedFile => _selectedFile;
  String? get nivelRiesgo => _nivelRiesgo;
  double? get probabilidadAlto => _probabilidadAlto;
  String? get prioridadVisita => _prioridadVisita;
  String? get motivoPrioridad => _motivoPrioridad;
  bool get isLoading => _status == MineriaStatus.loading;
  bool get isSaving => _status == MineriaStatus.saving;
  Map<String, TextEditingController> get controllers => _controllers;
  Future<void> init() async {
    _healthOk = await checkSaludUseCase();
    if (!hasListeners) return;
    if (_healthOk) {
      try {
        final catalogos = await getCatalogosUseCase();
        if (!hasListeners) return;
        vacunasOpts = catalogos['vacunas'] ?? [];
        dosisOpts = catalogos['dosis'] ?? [];
      } catch (e) {
        AppLogger.error('MineriaOCR: Error al cargar catálogos', e);
      }
    }
    notifyListeners();
  }

  Future<void> setFile(File file) async {
    _errorMessage = null;
    _selectedFile = null;
    notifyListeners();
    try {
      final length = await file.length();
      if (length <= 0) {
        _setError('El archivo está vacío.');
        return;
      }
      if (length > maxFileSizeBytes) {
        _setError(
          'El archivo supera el tamaño máximo permitido '
          '(${maxFileSizeBytes ~/ (1024 * 1024)} MB).',
        );
        return;
      }
      final raf = await file.open();
      List<int> header;
      try {
        header = await raf.read(_pdfMagicBytes.length);
      } finally {
        await raf.close();
      }
      final isPdf =
          header.length == _pdfMagicBytes.length &&
          _bytesEqual(header, _pdfMagicBytes);
      if (!isPdf) {
        _setError(
          'El archivo seleccionado no es un PDF válido (firma %PDF- no encontrada).',
        );
        return;
      }
      _selectedFile = file;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('No se pudo leer el archivo seleccionado.');
    }
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> procesar() async {
    if (_selectedFile == null) {
      _setError('Selecciona un archivo PDF primero.');
      return;
    }
    _status = MineriaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _result = await procesarPdfUseCase(_selectedFile!);
      AppLogger.info(
        'MineriaOCR: Extraídos ${_result?.campos.length ?? 0} campos.',
      );
      _initControllers();
      _status = MineriaStatus.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _initControllers() {
    _disposeControllers();
    _groupRegistry.clear();
    if (_result == null) return;
    final sortedKeys = _result!.campos.keys.toList()..sort();
    for (var key in sortedKeys) {
      final field = _result!.campos[key]!;
      String value = field.value.trim();
      final lowerValue = value.toLowerCase();
      final cleanKey = key.toLowerCase();
      if (cleanKey.contains('material_') ||
          cleanKey.contains('manejo_excretas') ||
          cleanKey.contains('tenencia')) {
        final baseKey = _getBaseKey(cleanKey);
        _groupRegistry.putIfAbsent(baseKey, () => []).add(key);
      }
      if (lowerValue == 'true') {
        value = key.split('.').last.replaceAll('_', ' ').toUpperCase();
      } else if (lowerValue == 'false' || lowerValue == '[vacío]') {
        value = '';
      }
      if (value.contains('%')) {
        value = value.split(RegExp(r'\d+%')).first.trim();
      }
      _controllers[key] = TextEditingController(text: value);
    }
  }

  String _getBaseKey(String key) {
    if (key.contains('material_techo')) return 'material_techo';
    if (key.contains('material_paredes')) return 'material_paredes';
    if (key.contains('material_piso')) return 'material_piso';
    if (key.contains('manejo_excretas')) return 'manejo_excretas';
    final parts = key.split('.');
    return parts.length > 1 ? parts[parts.length - 2] : parts[0];
  }

  void addVacuna() {
    vacunasSeleccionadas.add(VacunaAplicada());
    notifyListeners();
  }

  void removeVacuna(int index) {
    vacunasSeleccionadas.removeAt(index);
    notifyListeners();
  }

  void updateVacuna(int index, {String? vacuna, String? dosis}) {
    if (vacuna != null) vacunasSeleccionadas[index].vacuna = vacuna;
    if (dosis != null) vacunasSeleccionadas[index].dosis = dosis;
    notifyListeners();
  }

  Future<bool> guardarCambios() async {
    if (_result == null) return false;
    if (!(formKey.currentState?.validate() ?? false)) {
      _setError('Por favor, corrija los errores en el formulario.');
      return false;
    }
    _status = MineriaStatus.saving;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        "numero_cuartos": 2,
        "numero_habitantes": 4,
        "personas_por_cuarto": 2.0,
        "count_enfermedades_cronicas": 0,
        "count_toxicomanias": 0,
        "avg_dias_proteina": 4.0,
        "avg_dias_frutas_verduras": 4.0,
        "avg_dias_cereales": 5.0,
        "ingreso_nivel": 2,
        "escolaridad_promedio": 2.0,
        "total_integrantes": 4,
        "material_techo": "Concreto o cemento",
        "material_paredes": "Concreto o cemento",
        "material_piso": "Concreto o cemento",
        "manejo_excretas": "WC",
        "cocina_ubicacion": "fuera_del_dormitorio",
        "agua_entubada": true,
        "energia_electrica": true,
        "cocina_con_lena": false,
        "red_alcantarillado": true,
        "fosa_septica": false,
        "vacunacion_completa": true,
        "seguridad_social_jefe": false,
        // Banderas de grupos vulnerables (grupos_vulnerables.py en el backend):
        // no son features del modelo ML, se combinan con el nivel de riesgo
        // para decidir prioridad_visita. Sin un formulario dedicado en la app
        // para capturarlas todavía, se envían en false por defecto (mismo
        // comportamiento que tenía el endpoint antes de que existieran).
        "tiene_embarazada": false,
        "tiene_menor_1_anio": false,
        "tiene_menor_5_sin_vacunas": false,
        "tiene_adulto_mayor_solo": false,
        // 5ta bandera (riesgo zoonótico): mascota en la vivienda sin
        // vacunación al corriente. Igual que las 4 anteriores, no hay
        // formulario dedicado todavía para capturarla, se envía en false.
        "tiene_mascota_sin_vacunar": false,
      };
      _controllers.forEach((key, controller) {
        final value = controller.text.trim();
        final upperValue = value.toUpperCase();
        final cleanKey = key.toLowerCase();
        if (cleanKey.contains('numero_cuartos')) {
          payload['numero_cuartos'] = int.tryParse(value) ?? 2;
        }
        if (cleanKey.contains('numero_habitantes')) {
          payload['numero_habitantes'] = int.tryParse(value) ?? 4;
        }
        if (cleanKey.contains('agua_entubada.si') && value.isNotEmpty) {
          payload['agua_entubada'] = true;
        }
        if (cleanKey.contains('agua_entubada.no') && value.isNotEmpty) {
          payload['agua_entubada'] = false;
        }
        if (cleanKey.contains('energia_electrica.si') && value.isNotEmpty) {
          payload['energia_electrica'] = true;
        }
        if (cleanKey.contains('energia_electrica.no') && value.isNotEmpty) {
          payload['energia_electrica'] = false;
        }
        if (cleanKey.contains('material_techo') && value.isNotEmpty) {
          if (upperValue.contains('CONCRETO')) {
            payload['material_techo'] = 'Concreto o cemento';
          } else if (upperValue.contains('LAMINA')) {
            payload['material_techo'] = 'Lámina';
          } else if (upperValue.contains('MADERA')) {
            payload['material_techo'] = 'Madera';
          }
        }
        if (cleanKey.contains('material_paredes') && value.isNotEmpty) {
          if (upperValue.contains('CONCRETO')) {
            payload['material_paredes'] = 'Concreto o cemento';
          } else if (upperValue.contains('MADERA')) {
            payload['material_paredes'] = 'Madera';
          }
        }
        if (cleanKey.contains('material_piso') && value.isNotEmpty) {
          if (upperValue.contains('CONCRETO')) {
            payload['material_piso'] = 'Concreto o cemento';
          } else if (upperValue.contains('TIERRA')) {
            payload['material_piso'] = 'Tierra';
          }
        }
        if (cleanKey.contains('manejo_excretas') && value.isNotEmpty) {
          if (upperValue.contains('WC')) {
            payload['manejo_excretas'] = 'WC';
          } else if (upperValue.contains('LETRINA')) {
            payload['manejo_excretas'] = 'Letrina';
          }
        }
      });
      payload['vacunas'] = vacunasSeleccionadas
          .where((v) => v.isValid)
          .map((v) => v.toJson())
          .toList();
      AppLogger.info(
        'MineriaOCR: Enviando Payload Consolidado a /riesgo/predecir...',
      );
      final response = await predecirRiesgoUseCase(payload);
      AppLogger.info('Respuesta Riesgo: $response');

      _nivelRiesgo = response['nivel_riesgo'] as String?;
      final probRaw = response['probabilidad_alto'];
      _probabilidadAlto = probRaw is num ? probRaw.toDouble() : null;
      _prioridadVisita = response['prioridad_visita'] as String?;
      _motivoPrioridad = response['motivo_prioridad'] as String?;

      _status = MineriaStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('MineriaOCR: Error al guardar cambios', e);
      _status = MineriaStatus.success;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = MineriaStatus.initial;
    _result = null;
    _errorMessage = null;
    _selectedFile = null;
    _nivelRiesgo = null;
    _probabilidadAlto = null;
    _prioridadVisita = null;
    _motivoPrioridad = null;
    vacunasSeleccionadas.clear();
    _disposeControllers();
    notifyListeners();
  }

  void _setError(String message) {
    _status = MineriaStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _disposeControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}
