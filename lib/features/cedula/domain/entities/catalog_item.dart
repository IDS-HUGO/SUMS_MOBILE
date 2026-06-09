class CatalogItem {
  final int id;
  final String nombre;
  final String? descripcion;

  const CatalogItem({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: _asInt(json['id']) ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
