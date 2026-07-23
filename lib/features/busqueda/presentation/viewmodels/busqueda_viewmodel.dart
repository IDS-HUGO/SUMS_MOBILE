import 'package:flutter/foundation.dart';
import '../../../../core/network/app_logger.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/busqueda_repository.dart'
    show MotorNoDisponibleException;
import '../../domain/usecases/buscar_estructurado_usecase.dart';
import '../../domain/usecases/buscar_notas_usecase.dart';

enum BusquedaStatus { initial, loading, success, error }

/// "notas": /buscar (texto libre, BM25/TF-IDF/semántico).
/// "estructurado": /buscar/estructurado (filtro sobre vacunas/embarazo/
/// nutrición/mascotas/dirección -- datos que SIEMPRE existen en la cédula,
/// a diferencia de las notas de texto libre que suelen estar vacías).
enum ModoBusqueda { notas, estructurado }

class BusquedaViewModel extends ChangeNotifier {
  final BuscarNotasUseCase buscarNotasUseCase;
  final BuscarEstructuradoUseCase buscarEstructuradoUseCase;

  BusquedaViewModel({
    required this.buscarNotasUseCase,
    required this.buscarEstructuradoUseCase,
  });

  /// Motores soportados por el microservicio de búsqueda.
  static const List<String> motoresDisponibles = [
    'bm25',
    'tfidf',
    'semantico',
  ];

  static const int maxCaracteresConsulta = 500;

  // ── Estado ────────────────────────────────────────────────────────────────
  BusquedaStatus _status = BusquedaStatus.initial;
  ModoBusqueda _modo = ModoBusqueda.notas;
  String _motorSeleccionado = 'bm25';
  List<ResultadoBusqueda> _resultados = [];
  String? _errorMessage;
  bool _motorNoDisponible = false;
  String _ultimaConsulta = '';

  // ── Estado: búsqueda estructurada ──────────────────────────────────────────
  List<ResultadoBusquedaEstructurada> _resultadosEstructurados = [];
  String? _categoriaEncontrada;
  int _totalCoincidencias = 0;
  String? _mensajeSinCategoria;

  // ── Getters ───────────────────────────────────────────────────────────────
  BusquedaStatus get status => _status;
  ModoBusqueda get modo => _modo;
  String get motorSeleccionado => _motorSeleccionado;
  List<ResultadoBusqueda> get resultados => _resultados;
  String? get errorMessage => _errorMessage;
  bool get motorNoDisponible => _motorNoDisponible;
  bool get isLoading => _status == BusquedaStatus.loading;
  bool get isError => _status == BusquedaStatus.error;
  bool get hasBuscado => _status != BusquedaStatus.initial;

  List<ResultadoBusquedaEstructurada> get resultadosEstructurados =>
      _resultadosEstructurados;
  String? get categoriaEncontrada => _categoriaEncontrada;
  int get totalCoincidencias => _totalCoincidencias;
  String? get mensajeSinCategoria => _mensajeSinCategoria;

  /// Cambia entre búsqueda de notas (texto libre) y búsqueda estructurada
  /// (vacunas/embarazo/nutrición/mascotas/dirección). Limpia el estado de
  /// resultados previo para no mezclar resultados de un modo con el otro.
  void setModo(ModoBusqueda modo) {
    if (modo == _modo) return;
    _modo = modo;
    _status = BusquedaStatus.initial;
    _resultados = [];
    _resultadosEstructurados = [];
    _errorMessage = null;
    _motorNoDisponible = false;
    notifyListeners();
  }

  /// Cambia el motor seleccionado para la próxima búsqueda (solo aplica en
  /// modo "notas"; el modo "estructurado" no usa motor).
  void setMotor(String motor) {
    if (!motoresDisponibles.contains(motor) || motor == _motorSeleccionado) {
      return;
    }
    _motorSeleccionado = motor;
    notifyListeners();
  }

  /// Ejecuta la búsqueda con el modo actualmente seleccionado.
  Future<void> buscar(String consulta) async {
    final texto = consulta.trim();

    if (texto.isEmpty) {
      _status = BusquedaStatus.error;
      _motorNoDisponible = false;
      _errorMessage = 'Escribe un texto para buscar.';
      _resultados = [];
      _resultadosEstructurados = [];
      notifyListeners();
      return;
    }

    if (texto.length > maxCaracteresConsulta) {
      _status = BusquedaStatus.error;
      _motorNoDisponible = false;
      _errorMessage =
          'La consulta no puede superar los $maxCaracteresConsulta caracteres.';
      _resultados = [];
      _resultadosEstructurados = [];
      notifyListeners();
      return;
    }

    _ultimaConsulta = texto;
    _status = BusquedaStatus.loading;
    _errorMessage = null;
    _motorNoDisponible = false;
    notifyListeners();

    if (_modo == ModoBusqueda.notas) {
      await _buscarNotas(texto);
    } else {
      await _buscarEstructurado(texto);
    }
  }

  Future<void> _buscarNotas(String texto) async {
    try {
      final respuesta = await buscarNotasUseCase(
        texto,
        motor: _motorSeleccionado,
      );
      if (!hasListeners) return; // Evita error si el widget se cerró
      _resultados = respuesta.resultados;
      _status = BusquedaStatus.success;
      AppLogger.info(
        'Busqueda: ${_resultados.length} resultados para "$texto" '
        '(motor=$_motorSeleccionado)',
      );
      notifyListeners();
    } on MotorNoDisponibleException catch (e) {
      if (!hasListeners) return;
      AppLogger.warn(
        'Busqueda: motor "$_motorSeleccionado" no disponible en el servidor',
      );
      _resultados = [];
      _motorNoDisponible = true;
      _errorMessage = e.message;
      _status = BusquedaStatus.error;
      notifyListeners();
    } catch (e) {
      if (!hasListeners) return;
      AppLogger.error('Busqueda: Error al buscar', e);
      _resultados = [];
      _motorNoDisponible = false;
      _errorMessage = e.toString();
      _status = BusquedaStatus.error;
      notifyListeners();
    }
  }

  Future<void> _buscarEstructurado(String texto) async {
    try {
      final respuesta = await buscarEstructuradoUseCase(texto);
      if (!hasListeners) return;
      if (!respuesta.disponible) {
        _resultadosEstructurados = [];
        _totalCoincidencias = 0;
        _categoriaEncontrada = null;
        _mensajeSinCategoria = respuesta.mensaje;
        _status = BusquedaStatus.success;
      } else {
        _resultadosEstructurados = respuesta.resultados;
        _totalCoincidencias = respuesta.totalCoincidencias;
        _categoriaEncontrada = respuesta.categoria;
        _mensajeSinCategoria = null;
        _status = BusquedaStatus.success;
      }
      AppLogger.info(
        'BusquedaEstructurada: $_totalCoincidencias coincidencias para "$texto" '
        '(categoria=$_categoriaEncontrada)',
      );
      notifyListeners();
    } catch (e) {
      if (!hasListeners) return;
      AppLogger.error('BusquedaEstructurada: Error al buscar', e);
      _resultadosEstructurados = [];
      _errorMessage = e.toString();
      _status = BusquedaStatus.error;
      notifyListeners();
    }
  }

  /// Reintenta la última consulta realizada (útil tras un error o cambio de
  /// motor).
  void reintentar() {
    if (_ultimaConsulta.isNotEmpty) {
      buscar(_ultimaConsulta);
    }
  }

  /// Limpia el estado para una nueva búsqueda.
  void reset() {
    _status = BusquedaStatus.initial;
    _resultados = [];
    _resultadosEstructurados = [];
    _categoriaEncontrada = null;
    _totalCoincidencias = 0;
    _mensajeSinCategoria = null;
    _errorMessage = null;
    _motorNoDisponible = false;
    _ultimaConsulta = '';
    notifyListeners();
  }
}
