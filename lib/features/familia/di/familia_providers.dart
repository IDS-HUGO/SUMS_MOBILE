import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../presentation/viewmodels/familia_viewmodel.dart';

final familiaViewModelProvider =
    ChangeNotifierProvider.autoDispose<FamiliaViewModel>(
      (ref) => sl<FamiliaViewModel>(),
    );
