import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final digitsOnly = [FilteringTextInputFormatter.digitsOnly];

int? optionalInt(String value) {
  if (value.trim().isEmpty) return null;
  return int.tryParse(value.trim());
}

int requiredInt(String value) => int.parse(value.trim());

String todayIsoDate() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

String? requiredText(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  return null;
}

String? positiveIntText(String? value) {
  final parsed = int.tryParse(value ?? '');
  if (parsed == null || parsed <= 0) return 'Ingresa un ID valido';
  return null;
}

String? nonNegativeIntText(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) return 'Ingresa un numero valido';
  return null;
}

String? Function(String?) intMin(int min) {
  return (String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < min) return 'Debe ser al menos $min';
    return null;
  };
}

String? Function(String?) intRange(int min, int max) {
  return (String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < min || parsed > max) return 'Debe estar entre $min y $max';
    return null;
  };
}

class BooleanSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BooleanSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
