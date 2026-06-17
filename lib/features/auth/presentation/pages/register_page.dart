import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey             = GlobalKey<FormState>();
  final _userController      = TextEditingController();
  final _passwordController  = TextEditingController();
  final _roleController      = TextEditingController(text: '1');
  final _unidadController    = TextEditingController();
  final _laboralesController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    _unidadController.dispose();
    _laboralesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthViewModel>().register(
          nombreUsuario:    _userController.text.trim(),
          contrasena:       _passwordController.text,
          rolId:            int.parse(_roleController.text),
          unidadSaludId:    _optionalInt(_unidadController.text),
          datosLaboralesId: _optionalInt(_laboralesController.text),
        );
    if (!mounted || !success) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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
                                title: 'Registro de personal',
                                subtitle:
                                    'Alta de usuario para captura de cedulas comunitarias IMSS-BIENESTAR.',
                              ),
                            ),
                            const SizedBox(width: 36),
                            Expanded(child: _registerForm(viewModel)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const BrandHeader(
                              title:    'Registro de personal',
                              subtitle: 'Alta de usuario IMSS-BIENESTAR.',
                              compact:  true,
                            ),
                            const SizedBox(height: 24),
                            _registerForm(viewModel),
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

  Widget _registerForm(AuthViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crear usuario',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color:      AppColors.greenDark,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text('Completa los datos para registrarte en el sistema.'),
              const SizedBox(height: 20),

              // usuario
              SumsTextField(
                controller:      _userController,
                label:           'Nombre de usuario',
                icon:            Icons.person_add_outlined,
                textInputAction: TextInputAction.next,
                validator:       _required,
              ),
              const SizedBox(height: 14),

              // contraseña
              SumsTextField(
                controller:      _passwordController,
                label:           'Contrasena',
                icon:            Icons.lock_outline,
                obscureText:     true,
                textInputAction: TextInputAction.next,
                validator:       _required,
              ),
              const SizedBox(height: 14),

              // rol
              SumsTextField(
                controller:      _roleController,
                label:           'Rol ID',
                icon:            Icons.badge_outlined,
                keyboardType:    TextInputType.number,
                helperText:      'Debe existir en la tabla de roles de la API.',
                textInputAction: TextInputAction.next,
                validator:       _positiveInt,
              ),
              const SizedBox(height: 14),

              // unidad + laborales en fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SumsTextField(
                      controller:      _unidadController,
                      label:           'Unidad salud ID',
                      icon:            Icons.local_hospital_outlined,
                      keyboardType:    TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SumsTextField(
                      controller:      _laboralesController,
                      label:           'Datos laborales ID',
                      icon:            Icons.work_outline,
                      keyboardType:    TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),

              // error
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

              // botón principal
              FilledButton.icon(
                onPressed: viewModel.isLoading ? null : _submit,
                icon: viewModel.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Crear y entrar'),
              ),

              // botón secundario
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ya tengo usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _optionalInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) return 'Ingresa un ID valido';
    return null;
  }
}