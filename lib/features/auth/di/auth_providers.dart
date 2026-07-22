import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

final authViewModelProvider = ChangeNotifierProvider.autoDispose<AuthViewModel>(
  (ref) => sl<AuthViewModel>(),
);
