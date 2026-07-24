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
      _status = MineriaStatus.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
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

  /// [viviendaPayload] es el resultado de `ViviendaViewModel.toPayload()` --
  /// el MISMO formulario/estado que usa la captura manual real de cédula
  /// (ver FamiliaStepWidget/ViviendaStepWidget en mineria_page.dart), no un
  /// formulario paralelo propio de esta pantalla.
  Future<bool> guardarCambios(Map<String, dynamic> viviendaPayload) async {
    if (_result == null) return false;
    if (!(formKey.currentState?.validate() ?? false)) {
      _setError('Por favor, corrija los errores en el formulario.');
      return false;
    }
    _status = MineriaStatus.saving;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        // Features que ni OCR ni el formulario de Vivienda capturan hoy
        // (vienen de Integrantes/estilo de vida, fuera del alcance de esta
        // pantalla) -- se envían con un valor neutro razonable.
        "personas_por_cuarto": 2.0,
        "count_enfermedades_cronicas": 0,
        "count_toxicomanias": 0,
        "avg_dias_proteina": 4.0,
        "avg_dias_frutas_verduras": 4.0,
        "avg_dias_cereales": 5.0,
        "ingreso_nivel": 2,
        "escolaridad_promedio": 2.0,
        "total_integrantes": 4,
        "vacunacion_completa": true,
        "seguridad_social_jefe": false,
        "tiene_embarazada": false,
        "tiene_menor_1_anio": false,
        "tiene_menor_5_sin_vacunas": false,
        "tiene_adulto_mayor_solo": false,
      };

      final numeroCuartos = viviendaPayload['cuartos'] as int?;
      final numeroHabitantes = viviendaPayload['habitantes'] as int?;
      payload['numero_cuartos'] = numeroCuartos ?? 2;
      payload['numero_habitantes'] = numeroHabitantes ?? 4;
      payload['material_techo'] =
          viviendaPayload['techo'] ?? 'Concreto o cemento';
      payload['material_paredes'] =
          viviendaPayload['paredes'] ?? 'Concreto o cemento';
      payload['material_piso'] =
          viviendaPayload['piso'] ?? 'Concreto o cemento';
      payload['manejo_excretas'] = viviendaPayload['excretas'] ?? 'WC';
      payload['cocina_ubicacion'] = viviendaPayload['cocina'] == 'Dentro del dormitorio'
          ? 'dentro_del_dormitorio'
          : 'fuera_del_dormitorio';
      payload['agua_entubada'] = viviendaPayload['agua_entubada'] ?? true;
      payload['energia_electrica'] = viviendaPayload['energia_electrica'] ?? true;
      payload['cocina_con_lena'] = viviendaPayload['coccion_lena'] ?? false;
      payload['red_alcantarillado'] = viviendaPayload['red_alcantarillado'] ?? true;
      payload['fosa_septica'] = viviendaPayload['fosa_septica'] ?? false;

      // Riesgo zoonótico: mascota en la vivienda (perros/gatos) sin vacunas
      // al corriente. "animales_vacunas" en el formulario real significa
      // "SÍ tienen vacunas al corriente", por eso se niega.
      final tieneMascotas = viviendaPayload['perros_gatos'] == true;
      final mascotasVacunadas = viviendaPayload['animales_vacunas'] == true;
      payload['tiene_mascota_sin_vacunar'] = tieneMascotas && !mascotasVacunadas;

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
    notifyListeners();
  }

  void _setError(String message) {
    _status = MineriaStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
