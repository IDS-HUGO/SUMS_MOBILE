class AgeCalculator {
  /// Calcula la edad actual de forma dinámica basándose en la fecha de nacimiento.
  /// 
  /// Retorna un string con la edad en años, o en meses si es menor a 2 años.
  /// Formato de fecha esperado: YYYY-MM-DD
  static String calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.trim().isEmpty) return '';

    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      
      if (now.isBefore(birthDate)) return '0';

      int years = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        years--;
      }

      if (years < 2) {
        int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
        if (now.day < birthDate.day) months--;
        if (months < 0) months = 0;
        
        if (months == 0) {
          final days = now.difference(birthDate).inDays;
          return '$days ${days == 1 ? "día" : "días"}';
        }
        return '$months ${months == 1 ? "mes" : "meses"}';
      } else {
        return '$years ${years == 1 ? "año" : "años"}';
      }
    } catch (e) {
      return '';
    }
  }

  /// Retorna la edad puramente como entero (años).
  static int? calculateYears(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.trim().isEmpty) return null;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int years = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        years--;
      }
      return years < 0 ? 0 : years;
    } catch (_) {
      return null;
    }
  }
}
