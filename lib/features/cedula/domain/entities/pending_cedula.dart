import 'dart:convert';

enum PendingStatus { draft, pending, synced }

class PendingCedula {
  final int? id;
  final Map<String, dynamic> data;
  final PendingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? informanteNombre;

  const PendingCedula({
    this.id,
    required this.data,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.informanteNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'data': jsonEncode(data),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'informante_nombre': informanteNombre,
    };
  }

  factory PendingCedula.fromMap(Map<String, dynamic> map) {
    return PendingCedula(
      id: map['id'] as int?,
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      status: PendingStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      informanteNombre: map['informante_nombre'] as String?,
    );
  }

  PendingCedula copyWith({
    int? id,
    Map<String, dynamic>? data,
    PendingStatus? status,
    DateTime? updatedAt,
    String? informanteNombre,
  }) {
    return PendingCedula(
      id: id ?? this.id,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      informanteNombre: informanteNombre ?? this.informanteNombre,
    );
  }
}
