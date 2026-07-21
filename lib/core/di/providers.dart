/// Índice de los providers de Riverpod expuestos por cada feature.
///
/// Cada `xViewModelProvider` vive en `lib/features/x/di/x_providers.dart`,
/// junto a `x_injection.dart` (el registro de GetIt de esa misma feature).
/// Este archivo solo re-exporta esos providers para que el resto de la app
/// pueda seguir importando `core/di/providers.dart` sin cambios.
///
/// Agregar una feature nueva: crear `lib/features/<feature>/di/<feature>_providers.dart`
/// con su `ChangeNotifierProvider.autoDispose` y agregar una línea `export` aquí.
library;

export '../../features/auth/di/auth_providers.dart';
export '../../features/cedula_orquestador/di/cedula_providers.dart';
export '../../features/familia/di/familia_providers.dart';
export '../../features/vivienda/di/vivienda_providers.dart';
export '../../features/vacunacion/di/vacunacion_providers.dart';
export '../../features/integrantes/di/integrantes_providers.dart';
export '../../features/admin/di/admin_providers.dart';
export '../../features/estadisticas/di/estadisticas_providers.dart';
export '../../features/mineria/di/mineria_providers.dart';
