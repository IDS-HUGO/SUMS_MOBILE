import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/estadisticas_viewmodel.dart';

final estadisticasViewModelProvider =
    ChangeNotifierProvider.autoDispose<EstadisticasViewModel>(
      (ref) => sl<EstadisticasViewModel>(),
    );
