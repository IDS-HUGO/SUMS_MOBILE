class OcrField {
  final String key;
  final String value;
  final double confidence;
  final bool needsReview;

  const OcrField({
    required this.key,
    required this.value,
    required this.confidence,
    required this.needsReview,
  });

  /// Determina si la confianza es aceptable (ej. > 0.8)
  bool get isHighConfidence => confidence >= 0.8;
}
