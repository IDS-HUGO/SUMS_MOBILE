import 'package:flutter/material.dart';
import 'package:sums/shared/theme/app_theme.dart';

enum UserRole {
  superAdmin(0),
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
      case UserRole.superAdmin:
        return 'Super Administrador';
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

  Color get color {
    switch (this) {
      case UserRole.superAdmin:
        return const Color(0xff1a237e); // Azul muy oscuro para Super Admin
      case UserRole.admin:
        return AppColors.rolAdmin;
      case UserRole.medico:
        return AppColors.rolMedico;
      case UserRole.encuestador:
        return AppColors.rolEncuestador;
      case UserRole.analista:
        return AppColors.rolAnalista;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.superAdmin:
        return Icons.security;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.medico:
        return Icons.medical_services;
      case UserRole.encuestador:
        return Icons.assignment_ind;
      case UserRole.analista:
        return Icons.analytics;
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.superAdmin:
        return '/home/super-admin';
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
