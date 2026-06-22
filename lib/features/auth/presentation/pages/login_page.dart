import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey            = GlobalKey<FormState>();
  final _userController     = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      nombreUsuario: _userController.text.trim(),
      contrasena:    _passwordController.text,
    );

    if (!mounted || !success) return;

    // Redirige a la home correspondiente al rol del usuario
    Navigator.of(context).pushReplacementNamed(viewModel.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: BrandHeader(
                                title: 'Cédula de Microdiagnóstico Familiar',
                                subtitle:
                                    'Captura comunitaria alineada al modelo IMSS-BIENESTAR.',
                              ),
                            ),
                            const SizedBox(width: 36),
                            Expanded(child: _loginForm(viewModel)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const BrandHeader(
                              title:    'Cédula de Microdiagnóstico Familiar',
                              subtitle: 'Captura comunitaria IMSS-BIENESTAR.',
                              compact:  true,
                            ),
                            const SizedBox(height: 24),
                            _loginForm(viewModel),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loginForm(AuthViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key:              _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Iniciar sesión',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color:      AppColors.greenDark,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text('Usa tu usuario asignado por la unidad de salud.'),
              const SizedBox(height: 22),

              SumsTextField(
                controller:      _userController,
                label:           'Nombre de usuario',
                icon:            Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator:       _required,
              ),
              const SizedBox(height: 14),
              SumsTextField(
                controller:      _passwordController,
                label:           'Contraseña',
                icon:            Icons.lock_outline,
                obscureText:     true,
                textInputAction: TextInputAction.done,
                validator:       _required,
              ),

              // Error
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: viewModel.isLoading ? null : _submit,
                icon: viewModel.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:       Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_outlined),
                label: const Text('Entrar'),
              ),

              // Nota informativa (sin botón de registro)
              const SizedBox(height: 12),
              Text(
                'Si no tienes acceso, comunícate con el administrador de tu unidad de salud.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }
}