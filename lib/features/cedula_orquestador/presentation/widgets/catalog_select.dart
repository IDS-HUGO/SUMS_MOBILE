import 'package:flutter/material.dart';

import '../../domain/entities/catalog_item.dart';

class CatalogSelect extends StatelessWidget {
  final String label;
  final String catalogKey;
  final int? value;
  final IconData? icon;
  final Map<String, List<CatalogItem>> catalogs;
  final ValueChanged<int?> onChanged;
  final String? Function(int?)? validator;

  const CatalogSelect({
    super.key,
    required this.label,
    required this.catalogKey,
    required this.value,
    required this.catalogs,
    required this.onChanged,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final items = catalogs[catalogKey] ?? const <CatalogItem>[];
    
    // Safety check to ensure the current value exists in the catalog items
    final effectiveValue = items.any((item) => item.id == value) ? value : null;

    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: effectiveValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.nombre,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
