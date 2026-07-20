import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../presentation/viewmodels/mineria_viewmodel.dart';

final mineriaViewModelProvider =
    ChangeNotifierProvider.autoDispose<MineriaViewModel>(
      (ref) => sl<MineriaViewModel>(),
    );
