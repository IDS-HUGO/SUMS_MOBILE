import 'dart:io';
import '../entities/ocr_result.dart';

abstract class MineriaRepository {
  /// Procesa un archivo PDF mediante el microservicio OCR.
  Future<OcrResult> procesarPdf(File archivo);

  /// Verifica la disponibilidad del microservicio.
  Future<bool> checkSalud();
}
