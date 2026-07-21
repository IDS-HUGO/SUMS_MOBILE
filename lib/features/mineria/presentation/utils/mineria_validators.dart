class MineriaValidators {
  /// Obtiene la validación correspondiente para una clave de campo específica.
  static String? validate(String key, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final cleanValue = value.trim();

    final cleanKey = key.toUpperCase();

    // Lógica por tipo de campo (inferido por la clave)
    if (cleanKey.contains('NOMBRE') || 
        cleanKey.contains('PERSONA') || 
        cleanKey.contains('MATERIAL') ||
        cleanKey.contains('TENENCIA')) {
      return _validateName(cleanValue);
    }

    if (cleanKey.contains('EDAD') || 
        cleanKey.contains('INTEGRANTES') || 
        cleanKey.contains('CUARTOS') ||
        cleanKey.contains('HABITANTES')) {
      return _validateNumeric(cleanValue);
    }

    if (cleanKey.contains('FECHA')) {
      return _validateDate(cleanValue);
    }

    // Validación general para otros campos (alfanumérico básico)
    return _validateGeneral(cleanValue);
  }

  static String? _validateName(String value) {
    // Solo letras, espacios y tildes
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Ingrese un nombre válido (solo letras)';
    }
    if (value.length < 3) {
      return 'El nombre es demasiado corto';
    }
    return null;
  }

  static String? _validateNumeric(String value) {
    // Solo números
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) {
      return 'Ingrese solo números';
    }
    return null;
  }

  static String? _validateDate(String value) {
    // Formato simple DD/MM/AAAA o DD-MM-AAAA
    final dateRegex = RegExp(r'^\d{1,2}[/-]\d{1,2}[/-]\d{2,4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Formato de fecha inválido (DD/MM/AAAA)';
    }
    return null;
  }

  static String? _validateGeneral(String value) {
    if (value.length < 2) {
      return 'Dato demasiado corto';
    }
    return null;
  }
}
