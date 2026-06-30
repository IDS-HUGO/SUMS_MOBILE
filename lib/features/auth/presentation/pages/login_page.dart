import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
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
    Navigator.of(context).pushReplacementNamed(viewModel.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            if (isWide) {
              return Row(
                children: [
                  // Panel izquierdo — marca
                  Expanded(
                    child: Container(
                      color: AppColors.greenDark,
                      padding: const EdgeInsets.all(48),
                      child: const _BrandPanel(),
                    ),
                  ),
                  // Panel derecho — formulario
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _LoginCard(
                            formKey:            _formKey,
                            userController:     _userController,
                            passwordController: _passwordController,
                            onSubmit:           _submit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            // Vista móvil
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _MobileLoginHeader(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverToBoxAdapter(
                    child: _LoginCard(
                      formKey:            _formKey,
                      userController:     _userController,
                      passwordController: _passwordController,
                      onSubmit:           _submit,
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

// ── Panel de marca (desktop) ─────────────────────────────────────────────────

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/imss-bienestar-logo.png',
          width: 200,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        // Firma: borde izquierdo + texto
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cédula de Microdiagnóstico Familiar',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sistema de captura comunitaria alineado al modelo IMSS-BIENESTAR para zonas rurales de Chiapas.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Badges informativos
        Wrap(
          spacing: 10, runSpacing: 10,
          children: const [
            _InfoBadge(icon: Icons.location_on_outlined, text: 'Chiapas'),
            _InfoBadge(icon: Icons.people_outline, text: 'Zona Maya'),
            _InfoBadge(icon: Icons.verified_outlined, text: 'IMSS-Bienestar'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'SUMS v1.0',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header móvil ─────────────────────────────────────────────────────────────

class _MobileLoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greenDark,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/imss-bienestar-logo.png',
            width: 180,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Cédula de Microdiagnóstico Familiar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Captura comunitaria IMSS-BIENESTAR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Formulario de login ───────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDark.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key:              formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícono superior
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.green,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.greenDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Usa el usuario asignado por tu unidad de salud.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 28),

            // Error banner
            if (viewModel.errorMessage != null) ...[
              _ErrorBanner(message: viewModel.errorMessage!),
              const SizedBox(height: 16),
            ],

            SumsTextField(
              controller:      userController,
              label:           'Nombre de usuario',
              icon:            Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator:       _required,
            ),
            const SizedBox(height: 14),
            SumsTextField(
              controller:      passwordController,
              label:           'Contraseña',
              icon:            Icons.lock_outline,
              obscureText:     true,
              textInputAction: TextInputAction.done,
              validator:       _required,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: viewModel.isLoading ? null : onSubmit,
              icon: viewModel.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login_outlined, size: 18),
              label: Text(viewModel.isLoading ? 'Verificando…' : 'Entrar'),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin acceso, contacta al administrador de tu unidad de salud.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
