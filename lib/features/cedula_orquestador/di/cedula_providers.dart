import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/cedula_viewmodel.dart';

final cedulaViewModelProvider =
    ChangeNotifierProvider.autoDispose<CedulaViewModel>(
      (ref) => sl<CedulaViewModel>(),
    );
