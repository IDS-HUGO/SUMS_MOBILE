import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/admin_catalogos_viewmodel.dart';
import '../presentation/viewmodels/admin_unidades_viewmodel.dart';
import '../presentation/viewmodels/admin_users_viewmodel.dart';

final adminUsersViewModelProvider =
    ChangeNotifierProvider.autoDispose<AdminUsersViewModel>(
      (ref) => sl<AdminUsersViewModel>(),
    );

final adminUnidadesViewModelProvider =
    ChangeNotifierProvider.autoDispose<AdminUnidadesViewModel>(
      (ref) => sl<AdminUnidadesViewModel>(),
    );

final adminCatalogosViewModelProvider =
    ChangeNotifierProvider.autoDispose<AdminCatalogosViewModel>(
      (ref) => sl<AdminCatalogosViewModel>(),
    );
