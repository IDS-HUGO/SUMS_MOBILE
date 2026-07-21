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

  /// Tamaño máximo permitido para el PDF antes de enviarlo al microservicio
  /// OCR (protege memoria/ancho de banda contra archivos maliciosamente
  /// grandes).
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20 MB

  /// Firma mágica de un PDF válido: los bytes ASCII de "%PDF-".
  static const List<int> _pdfMagicBytes = [0x25, 0x50, 0x44, 0x46, 0x2D];

  // ── Estado ────────────────────────────────────────────────────────────────
  MineriaStatus _status = MineriaStatus.initial;
  bool _healthOk = false;
  OcrResult? _result;
  String? _errorMessage;
  File? _selectedFile;

  // Catálogos
  List<String> vacunasOpts = [];
  List<String> dosisOpts = [];

  // Vacunas seleccionadas manualmente
  final List<VacunaAplicada> vacunasSeleccionadas = [];

  // Llave del formulario para validaciones Regex
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Mapa de controladores para edición
  final Map<String, TextEditingController> _controllers = {};

  // Mapeo de grupos para reconstruir el payload original (BaseKey -> List of original sub-keys)
  final Map<String, List<String>> _groupRegistry = {};

  // ── Getters ───────────────────────────────────────────────────────────────
  MineriaStatus get status => _status;
  bool get healthOk => _healthOk;
  OcrResult? get result => _result;
  String? get errorMessage => _errorMessage;
  File? get selectedFile => _selectedFile;
  bool get isLoading => _status == MineriaStatus.loading;
  bool get isSaving => _status == MineriaStatus.saving;
  Map<String, TextEditingController> get controllers => _controllers;

  // ── Acciones ──────────────────────────────────────────────────────────────

  /// Verifica si el servicio está disponible y carga catálogos.
  Future<void> init() async {
    _healthOk = await checkSaludUseCase();
    if (!hasListeners) return; // Evita error si el widget se cerró

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

  /// Establece el archivo PDF seleccionado, validando tamaño y firma mágica
  /// (%PDF-) ANTES de habilitar su envío al microservicio OCR. Si la
  /// validación falla, no se guarda el archivo como seleccionado.
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

  /// Envía el archivo al OCR.
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

  /// Inicializa los controladores con los valores extraídos.
  /// Mapeo 1:1 para asegurar que se muestren todos los campos (aprox. 45).
  void _initControllers() {
    _disposeControllers();
    _groupRegistry.clear();
    if (_result == null) return;

    // Ordenar llaves alfabéticamente para consistencia visual
    final sortedKeys = _result!.campos.keys.toList()..sort();

    for (var key in sortedKeys) {
      final field = _result!.campos[key]!;
      String value = field.value.trim();
      final lowerValue = value.toLowerCase();
      final cleanKey = key.toLowerCase();

      // Registrar grupos para el mapeo consolidado posterior
      if (cleanKey.contains('material_') || 
          cleanKey.contains('manejo_excretas') || 
          cleanKey.contains('tenencia')) {
        final baseKey = _getBaseKey(cleanKey);
        _groupRegistry.putIfAbsent(baseKey, () => []).add(key);
      }

      // Sanitización y mejora de visualización
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

  // Gestión de Vacunas
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

  /// Valida y guarda los datos editados + vacunas.
  Future<bool> guardarCambios() async {
    if (_result == null) return false;

    // Ejecutar validaciones Regex
    if (!(formKey.currentState?.validate() ?? false)) {
      _setError('Por favor, corrija los errores en el formulario.');
      return false;
    }

    _status = MineriaStatus.saving;
    notifyListeners();

    try {
      // 1. Construir payload para FamiliaFeatures (Python)
      // Inicializamos con valores por defecto seguros
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
      };

      // Mapeamos los 45 campos del OCR al payload consolidado
      _controllers.forEach((key, controller) {
        final value = controller.text.trim();
        final upperValue = value.toUpperCase();
        final cleanKey = key.toLowerCase();

        // Mapeo de campos numéricos
        if (cleanKey.contains('numero_cuartos')) {
          payload['numero_cuartos'] = int.tryParse(value) ?? 2;
        }
        if (cleanKey.contains('numero_habitantes')) {
          payload['numero_habitantes'] = int.tryParse(value) ?? 4;
        }

        // Mapeo de booleanos
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

        // Mapeo de Categorías (Materiales)
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

      // 2. Añadir vacunas
      payload['vacunas'] =
          vacunasSeleccionadas
              .where((v) => v.isValid)
              .map((v) => v.toJson())
              .toList();

      AppLogger.info('MineriaOCR: Enviando Payload Consolidado a /riesgo/predecir...');
      final response = await predecirRiesgoUseCase(payload);
      AppLogger.info('Respuesta Riesgo: $response');

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

  /// Limpia el estado para un nuevo procesamiento.
  void reset() {
    _status = MineriaStatus.initial;
    _result = null;
    _errorMessage = null;
    _selectedFile = null;
    vacunasSeleccionadas.clear();
    _disposeControllers();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
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
