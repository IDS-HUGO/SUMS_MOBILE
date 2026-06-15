import 'package:flutter/material.dart';

import '../../domain/entities/catalog_item.dart';

class CatalogSelect extends StatelessWidget {
  final String label;
  final String catalogKey;
  final int? value;
  final Map<String, List<CatalogItem>> catalogs;
  final ValueChanged<int?> onChanged;

  const CatalogSelect({
    super.key,
    required this.label,
    required this.catalogKey,
    required this.value,
    required this.catalogs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = catalogs[catalogKey] ?? const <CatalogItem>[];
    return DropdownButtonFormField<int>(
      initialValue: items.any((item) => item.id == value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.nombre),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
