import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import 'package:flutter/services.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../widgets/brand_panel.dart';
import '../widgets/login_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initScreenProtector();
  }

  static const platform = MethodChannel('com.kazedev.sums/security');

  void _initScreenProtector() async {
    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('secureScreen');
      } catch (e) {
        // Ignore
      }
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      try {
        platform.invokeMethod('unsecureScreen');
      } catch (e) {
        // Ignore
      }
    }
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = ref.read(authViewModelProvider);
    final success = await viewModel.login(
      nombreUsuario: _userController.text.trim(),
      contrasena: _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      await _showSuccessDialog();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(viewModel.homeRoute);
    } else {
      await _showErrorDialog(viewModel);
    }
  }

  Future<void> _showSuccessDialog() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text('Éxito', style: TextStyle(color: theme.colorScheme.onSurface)),
          ],
        ),
        content: const Text('Inicio de sesión exitoso. Bienvenido a SUMS.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continuar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(AuthViewModel viewModel) async {
    final theme = Theme.of(context);
    final errorMsg = viewModel.errorMessage?.toLowerCase() ?? '';
    final isConnection =
        errorMsg.contains('conexión') ||
        errorMsg.contains('network') ||
        errorMsg.contains('socket') ||
        errorMsg.contains('timeout');

    final title = isConnection ? 'Falla de conexión' : 'Contraseña incorrecta';
    final msg = isConnection
        ? 'No pudimos conectarnos al servidor. Revisa tu conexión a internet.'
        : 'El usuario o contraseña ingresados no son correctos.';
    final icon = isConnection ? Icons.wifi_off : Icons.lock_outline;
    final iconColor = isConnection
        ? theme.colorScheme.error
        : theme.colorScheme.error;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.primary,
                      padding: const EdgeInsets.all(48),
                      child: const BrandPanel(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: LoginCard(
                            formKey: _formKey,
                            userController: _userController,
                            passwordController: _passwordController,
                            onSubmit: _submit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: MobileLoginHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                  sliver: SliverToBoxAdapter(
                    child: LoginCard(
                      formKey: _formKey,
                      userController: _userController,
                      passwordController: _passwordController,
                      onSubmit: _submit,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
