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
