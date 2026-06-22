import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'administrador';

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BrandHeader(
                    title:    'Hola, $userName',
                    subtitle: 'Panel de administración del sistema SUMS.',
                    compact:  true,
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, 'Gestión del sistema'),
                  const SizedBox(height: 12),
                  _grid([
                    _ActionCard(
                      icon:    Icons.people_outline,
                      label:   'Usuarios',
                      color:   AppColors.greenDark,
                      onTap:   () {},
                    ),
                    _ActionCard(
                      icon:    Icons.local_hospital_outlined,
                      label:   'Unidades de salud',
                      color:   AppColors.green,
                      onTap:   () {},
                    ),
                    _ActionCard(
                      icon:    Icons.dataset_outlined,
                      label:   'Catálogos',
                      color:   AppColors.burgundy,
                      onTap:   () {},
                    ),
                    _ActionCard(
                      icon:    Icons.bar_chart_outlined,
                      label:   'Reportes',
                      color:   AppColors.gold,
                      onTap:   () {},
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: const Text('SUMS · Administrador'),
        actions: [_logoutButton(context)],
      );

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color:      AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
      );

  Widget _grid(List<Widget> cards) => LayoutBuilder(
        builder: (_, constraints) {
          final cols = constraints.maxWidth >= 600 ? 2 : 1;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((c) => SizedBox(
                      width: (constraints.maxWidth - 12 * (cols - 1)) / cols,
                      child: c,
                    ))
                .toList(),
          );
        },
      );

  Widget _logoutButton(BuildContext context) => IconButton(
        tooltip:  'Cerrar sesión',
        icon:     const Icon(Icons.logout_outlined),
        onPressed: () async {
          await context.read<AuthViewModel>().logout();
          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (_) => false,
          );
        },
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap:         onTap,
        borderRadius:  BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                child:           Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}