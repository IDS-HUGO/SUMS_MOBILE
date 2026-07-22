import 'dart:io';
import '../entities/ocr_result.dart';
import '../repositories/mineria_repository.dart';

class ProcesarPdfUseCase {
  final MineriaRepository repository;
  const ProcesarPdfUseCase(this.repository);
  Future<OcrResult> call(File archivo) {
    return repository.procesarPdf(archivo);
  }
}
