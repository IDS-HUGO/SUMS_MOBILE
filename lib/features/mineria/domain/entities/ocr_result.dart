import 'ocr_field.dart';
import 'ocr_summary.dart';

class OcrResult {
  final String docId;
  final String archivoOriginal;
  final int nPaginas;
  final Map<String, OcrField> campos;
  final OcrSummary resumen;
  const OcrResult({
    required this.docId,
    required this.archivoOriginal,
    required this.nPaginas,
    required this.campos,
    required this.resumen,
  });
}
