import 'dart:io';
import '../entities/ocr_result.dart';

abstract class MineriaRepository {
  Future<OcrResult> procesarPdf(File archivo);
  Future<bool> checkSalud();
  Future<Map<String, List<String>>> getCatalogos();
  Future<Map<String, dynamic>> predecirRiesgo(Map<String, dynamic> payload);
}
