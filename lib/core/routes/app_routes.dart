import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/home_admin_page.dart';
import '../../features/auth/presentation/pages/home_analista_page.dart';
import '../../features/auth/presentation/pages/home_encuestador_page.dart';
import '../../features/auth/presentation/pages/home_medico_page.dart';
import '../../features/admin/presentation/pages/admin_users_list_page.dart';
import '../../features/admin/presentation/pages/admin_unidades_list_page.dart';
import '../../features/admin/presentation/pages/admin_catalogos_page.dart';
import '../../features/admin/presentation/pages/admin_reportes_page.dart';
import '../../features/admin/presentation/pages/admin_productividad_page.dart';
import '../../features/admin/presentation/pages/admin_cedulas_list_page.dart';
import '../../features/admin/presentation/pages/admin_unidad_form_page.dart';
import '../../features/admin/presentation/pages/admin_user_form_page.dart';
import '../../features/mineria/presentation/pages/mineria_page.dart';
import '../../features/estadisticas/presentation/pages/productividad_admin_page.dart';
import '../../features/cedula_orquestador/presentation/pages/cedula_form_page.dart';
import '../../features/cedula_orquestador/presentation/pages/pending_captures_page.dart';
import '../../features/cedula_orquestador/presentation/pages/cedula_history_page.dart';

class AppRoutes {
  static const login = '/login';
  static const homeAdmin = '/home/admin';
  static const homeMedico = '/home/medico';
  static const homeEncuestador = '/home/encuestador';
  static const homeAnalista = '/home/analista';
  static const cedula = '/cedula';
  static const pending = '/cedula/pending';
  static const cedulaHistorial = '/cedula/historial';

  static const adminUsers = '/admin/users';
  static const adminUnidades = '/admin/unidades';
  static const adminCatalogos = '/admin/catalogos';
  static const adminReportes = '/admin/reportes';
  static const adminProductividad = '/admin/productividad';
  static const productividadAdmin = '/admin/productividad_admin';
  static const adminCedulas = '/admin/cedulas';
  static const adminMineria = '/admin/mineria';
  static const adminUnidadForm = '/admin/unidades/form';
  static const adminUserForm = '/admin/users/form';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final authViewModel = sl<AuthViewModel>();
    final isAuthenticated = authViewModel.isAuthenticated;
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;

    if (!isAuthenticated && !isGoingToLogin) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isGoingToLogin) {
      return authViewModel.homeRoute;
    }

    if (state.matchedLocation.startsWith('/admin')) {
      if (authViewModel.role != UserRole.admin) {
        return authViewModel.homeRoute;
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.homeAdmin,
      builder: (context, state) => const HomeAdminPage(),
    ),
    GoRoute(
      path: AppRoutes.homeMedico,
      builder: (context, state) => const HomeMedicoPage(),
    ),
    GoRoute(
      path: AppRoutes.homeEncuestador,
      builder: (context, state) => const HomeEncuestadorPage(),
    ),
    GoRoute(
      path: AppRoutes.homeAnalista,
      builder: (context, state) => const HomeAnalistaPage(),
    ),
    GoRoute(
      path: AppRoutes.cedula,
      builder: (context, state) => const CedulaFormPage(),
    ),
    GoRoute(
      path: AppRoutes.pending,
      builder: (context, state) => const PendingCapturesPage(),
    ),
    GoRoute(
      path: AppRoutes.cedulaHistorial,
      builder: (context, state) => const CedulaHistoryPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsersListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUnidades,
      builder: (context, state) => const AdminUnidadesListPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCatalogos,
      builder: (context, state) => const AdminCatalogosPage(),
    ),
    GoRoute(
      path: AppRoutes.adminReportes,
      builder: (context, state) => const AdminReportesPage(),
    ),
    GoRoute(
      path: AppRoutes.adminProductividad,
      builder: (context, state) => const AdminProductividadPage(),
    ),
    GoRoute(
      path: AppRoutes.adminCedulas,
      builder: (context, state) => const AdminCedulasListPage(),
    ),
    GoRoute(
      path: AppRoutes.productividadAdmin,
      builder: (context, state) => const ProductividadAdminPage(),
    ),
    GoRoute(
      path: AppRoutes.adminMineria,
      builder: (context, state) => const MineriaPage(),
    ),
    GoRoute(
      path: AppRoutes.adminUnidadForm,
      builder: (context, state) {
        final unidad = state.extra;
        return AdminUnidadFormPage(unidad: unidad as dynamic);
      },
    ),
    GoRoute(
      path: AppRoutes.adminUserForm,
      builder: (context, state) {
        final user = state.extra;
        return AdminUserFormPage(user: user as dynamic);
      },
    ),
  ],
);
