import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../presentation/viewmodels/integrantes_viewmodel.dart';

final integrantesViewModelProvider =
    ChangeNotifierProvider.autoDispose<IntegrantesViewModel>(
      (ref) => sl<IntegrantesViewModel>(),
    );
