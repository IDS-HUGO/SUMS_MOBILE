import '../../domain/entities/ocr_field.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/ocr_summary.dart';

class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.docId,
    required super.archivoOriginal,
    required super.nPaginas,
    required super.campos,
    required super.resumen,
  });
  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    final camposJson = json['campos'] as Map<String, dynamic>? ?? {};
    final camposMap = <String, OcrField>{};
    camposJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        camposMap[key] = OcrFieldModel.fromJson(key, value);
      }
    });
    return OcrResultModel(
      docId: json['doc_id']?.toString() ?? '',
      archivoOriginal: json['archivo_original']?.toString() ?? '',
      nPaginas: _asInt(json['n_paginas']) ?? 0,
      campos: camposMap,
      resumen: OcrSummaryModel.fromJson(json['resumen'] ?? {}),
    );
  }
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class OcrFieldModel extends OcrField {
  const OcrFieldModel({
    required super.key,
    required super.value,
    required super.confidence,
    required super.needsReview,
  });
  factory OcrFieldModel.fromJson(String key, Map<String, dynamic> json) {
    return OcrFieldModel(
      key: key,
      value: json['value']?.toString() ?? '',
      confidence: _asDouble(json['confidence']) ?? 0.0,
      needsReview: json['needs_review'] == true,
    );
  }
  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class OcrSummaryModel extends OcrSummary {
  const OcrSummaryModel({
    required super.totalCampos,
    required super.necesitanRevision,
  });
  factory OcrSummaryModel.fromJson(Map<String, dynamic> json) {
    return OcrSummaryModel(
      totalCampos: _asInt(json['total_campos']) ?? 0,
      necesitanRevision: _asInt(json['necesitan_revision']) ?? 0,
    );
  }
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
