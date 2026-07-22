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
  bool get isHighConfidence => confidence >= 0.8;
}
