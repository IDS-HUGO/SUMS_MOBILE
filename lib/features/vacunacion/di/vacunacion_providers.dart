import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/vacunacion_viewmodel.dart';

final vacunacionViewModelProvider =
    ChangeNotifierProvider.autoDispose<VacunacionViewModel>(
      (ref) => sl<VacunacionViewModel>(),
    );
