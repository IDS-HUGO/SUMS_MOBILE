import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeAnalistaPage extends ConsumerWidget {
  const HomeAnalistaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName =
        ref.watch(authViewModelProvider).session?.user.nombreUsuario ??
        'analista';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUMS · Analista'),
        actions: [_logoutButton(context, ref)],
      ),
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
                    title: 'Hola, $userName',
                    subtitle:
                        'Análisis y estadísticas del programa IMSS-Bienestar.',
                    compact: true,
                  ),
                  const SizedBox(height: 22),
                  _card(
                    context,
                    icon: Icons.vaccines_outlined,
                    title: 'Estadísticas de vacunación',
                    sub: 'Aplicaciones por vacuna, dosis, edad y sexo.',
                    color: AppColors.green,
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    icon: Icons.family_restroom_outlined,
                    title: 'Núcleos familiares',
                    sub: 'Composición y distribución por localidad.',
                    color: AppColors.greenDark,
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Condiciones de vivienda',
                    sub: 'Materiales, servicios básicos y saneamiento.',
                    color: AppColors.burgundy,
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    icon: Icons.monitor_heart_outlined,
                    title: 'Salud preventiva',
                    sub: 'Tamizajes, enfermedades crónicas y toxicomanías.',
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required Color color,
  }) => Card(
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.greenDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );

  Widget _logoutButton(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: 'Cerrar sesión',
    icon: const Icon(Icons.logout_outlined),
    onPressed: () async {
      await ref.read(authViewModelProvider).logout();
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    },
  );
}
