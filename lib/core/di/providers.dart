import 'package:sums/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'injection.dart';

import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';
import '../../features/familia/presentation/viewmodels/familia_viewmodel.dart';
import '../../features/vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import '../../features/vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';
import '../../features/integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_users_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_unidades_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_catalogos_viewmodel.dart';
import '../../features/estadisticas/presentation/viewmodels/estadisticas_viewmodel.dart';

// Definimos los providers de Riverpod usando autoDispose para la gestión del ciclo de vida de la pantalla.
// Las instancias reales se resuelven usando get_it (sl).

final authViewModelProvider = ChangeNotifierProvider.autoDispose<AuthViewModel>((ref) {
  return sl<AuthViewModel>();
});

final cedulaViewModelProvider = ChangeNotifierProvider.autoDispose<CedulaViewModel>((ref) {
  return sl<CedulaViewModel>();
});

final familiaViewModelProvider = ChangeNotifierProvider.autoDispose<FamiliaViewModel>((ref) {
  return sl<FamiliaViewModel>();
});

final viviendaViewModelProvider = ChangeNotifierProvider.autoDispose<ViviendaViewModel>((ref) {
  return sl<ViviendaViewModel>();
});

final vacunacionViewModelProvider = ChangeNotifierProvider.autoDispose<VacunacionViewModel>((ref) {
  return sl<VacunacionViewModel>();
});

final integrantesViewModelProvider = ChangeNotifierProvider.autoDispose<IntegrantesViewModel>((ref) {
  return sl<IntegrantesViewModel>();
});

final adminUsersViewModelProvider = ChangeNotifierProvider.autoDispose<AdminUsersViewModel>((ref) {
  return sl<AdminUsersViewModel>();
});

final adminUnidadesViewModelProvider = ChangeNotifierProvider.autoDispose<AdminUnidadesViewModel>((ref) {
  return sl<AdminUnidadesViewModel>();
});

final adminCatalogosViewModelProvider = ChangeNotifierProvider.autoDispose<AdminCatalogosViewModel>((ref) {
  return sl<AdminCatalogosViewModel>();
});

final estadisticasViewModelProvider = ChangeNotifierProvider.autoDispose<EstadisticasViewModel>((ref) {
  return sl<EstadisticasViewModel>();
});
