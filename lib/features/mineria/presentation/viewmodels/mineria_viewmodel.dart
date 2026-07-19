import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/usecases/check_salud_usecase.dart';
import '../../domain/usecases/procesar_pdf_usecase.dart';

enum MineriaStatus { initial, loading, success, error }

class MineriaViewModel extends ChangeNotifier {
  final ProcesarPdfUseCase procesarPdfUseCase;
  final CheckSaludUseCase checkSaludUseCase;

  MineriaViewModel({
    required this.procesarPdfUseCase,
    required this.checkSaludUseCase,
  });

  // ── Estado ────────────────────────────────────────────────────────────────
  MineriaStatus _status = MineriaStatus.initial;
  bool _healthOk = false;
  OcrResult? _result;
  String? _errorMessage;
  File? _selectedFile;

  // ── Getters ───────────────────────────────────────────────────────────────
  MineriaStatus get status => _status;
  bool get healthOk => _healthOk;
  OcrResult? get result => _result;
  String? get errorMessage => _errorMessage;
  File? get selectedFile => _selectedFile;
  bool get isLoading => _status == MineriaStatus.loading;

  // ── Acciones ──────────────────────────────────────────────────────────────

  /// Verifica si el servicio está disponible.
  Future<void> init() async {
    _healthOk = await checkSaludUseCase();
    notifyListeners();
  }

  /// Establece el archivo PDF seleccionado.
  void setFile(File file) {
    _selectedFile = file;
    _errorMessage = null;
    notifyListeners();
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
      _status = MineriaStatus.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Limpia el estado para un nuevo procesamiento.
  void reset() {
    _status = MineriaStatus.initial;
    _result = null;
    _errorMessage = null;
    _selectedFile = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setError(String message) {
    _status = MineriaStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
