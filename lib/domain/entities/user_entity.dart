class UserEntity {
  final int id;
  final String nombreUsuario;
  final int rolId;
  final DateTime? fechaRegistro;
  final bool activo;
  final int? unidadSaludId;
  final int? datosLaboralesId;

  UserEntity({
    required this.id,
    required this.nombreUsuario,
    required this.rolId,
    this.fechaRegistro,
    this.activo = true,
    this.unidadSaludId,
    this.datosLaboralesId,
  });

  String get roleName {
    switch (rolId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Capturista de Campo';
      case 3:
        return 'Médico Evaluador';
      default:
        return 'Usuario General (Rol $rolId)';
    }
  }

  String get roleDescription {
    switch (rolId) {
      case 1:
        return 'Gestión general de usuarios, asignación de clínicas y control administrativo del sistema.';
      case 2:
        return 'Responsable de la captura en campo de Cédulas de Microdiagnóstico Familiar.';
      case 3:
        return 'Personal médico a cargo de la evaluación, diagnóstico e interpretación de datos.';
      default:
        return 'Usuario con acceso básico al sistema de microdiagnóstico.';
    }
  }

  String get clinicName {
    if (unidadSaludId == null) return 'Sin Clínica Asignada';
    switch (unidadSaludId) {
      case 101:
        return 'Hospital General Regional IMSS-BIENESTAR';
      case 102:
        return 'Unidad Médica Familiar (UMF) No. 1';
      case 103:
        return 'Clínica Rural de Atención Primaria No. 23';
      default:
        return 'Clínica de Salud IMSS-BIENESTAR #$unidadSaludId';
    }
  }

  String get laborDetails {
    if (datosLaboralesId == null) return 'Sin Registro Laboral';
    switch (datosLaboralesId) {
      case 201:
        return 'Personal de Base - Contrato Permanente';
      case 202:
        return 'Personal Eventual - Contrato Temporal';
      case 203:
        return 'Personal de Confianza / Directivo';
      default:
        return 'Registro Laboral ID: #$datosLaboralesId';
    }
  }
}
