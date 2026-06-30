class PendingCedula {
  final int? id;
  final String payload;
  final DateTime updatedAt;

  PendingCedula({
    this.id,
    required this.payload,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'payload': payload,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PendingCedula.fromMap(Map<String, dynamic> map) {
    return PendingCedula(
      id: map['id'] as int?,
      payload: map['payload'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
