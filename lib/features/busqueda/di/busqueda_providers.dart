import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/busqueda_viewmodel.dart';

final busquedaViewModelProvider =
    ChangeNotifierProvider.autoDispose<BusquedaViewModel>(
      (ref) => sl<BusquedaViewModel>(),
    );
