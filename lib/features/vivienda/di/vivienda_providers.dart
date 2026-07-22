import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../presentation/viewmodels/vivienda_viewmodel.dart';

final viviendaViewModelProvider =
    ChangeNotifierProvider.autoDispose<ViviendaViewModel>(
      (ref) => sl<ViviendaViewModel>(),
    );
