import 'dart:io';
import '../entities/ocr_result.dart';

abstract class MineriaRepository {
  /// Procesa un archivo PDF mediante el microservicio OCR.
  Future<OcrResult> procesarPdf(File archivo);

  /// Verifica la disponibilidad del microservicio.
  Future<bool> checkSalud();

  /// Obtiene los catálogos de vacunas y dosis.
  Future<Map<String, List<String>>> getCatalogos();

  /// Envía los datos finales para predicción de riesgo y guardado.
  Future<Map<String, dynamic>> predecirRiesgo(Map<String, dynamic> payload);
}
