enum UserRole {
  admin(1),
  medico(2),
  encuestador(4),
  analista(3);

  final int id;
  const UserRole(this.id);

  static UserRole fromId(int rolId) {
    return UserRole.values.firstWhere(
      (r) => r.id == rolId,
      orElse: () => UserRole.encuestador,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.medico:
        return 'Médico';
      case UserRole.encuestador:
        return 'Encuestador';
      case UserRole.analista:
        return 'Analista de datos';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.admin:
        return '/home/admin';
      case UserRole.medico:
        return '/home/medico';
      case UserRole.encuestador:
        return '/home/encuestador';
      case UserRole.analista:
        return '/home/analista';
    }
  }
}
