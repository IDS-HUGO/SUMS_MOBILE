import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeMedicoPage extends StatelessWidget {
  const HomeMedicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>().session?.user.nombreUsuario ?? 'médico';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUMS · Médico'),
        actions: [_logoutButton(context)],
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
                    title:    'Hola, Dr. $userName',
                    subtitle: 'Consulta y seguimiento de pacientes IMSS-Bienestar.',
                    compact:  true,
                  ),
                  const SizedBox(height: 22),
                  _card(
                    context,
                    icon:     Icons.vaccines_outlined,
                    title:    'Esquemas de vacunación',
                    subtitle: 'Registra y consulta inmunizaciones por persona.',
                    color:    AppColors.green,
                    onTap:    () {},
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    icon:     Icons.people_alt_outlined,
                    title:    'Personas',
                    subtitle: 'Datos personales y perfil de salud de cada integrante.',
                    color:    AppColors.greenDark,
                    onTap:    () {},
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    icon:     Icons.health_and_safety_outlined,
                    title:    'Salud preventiva',
                    subtitle: 'Tamizajes, atención de embarazo y seguimiento.',
                    color:    AppColors.burgundy,
                    onTap:    () {},
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
    required IconData  icon,
    required String    title,
    required String    subtitle,
    required Color     color,
    required VoidCallback onTap,
  }) =>
      Card(
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child:           Icon(icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color:      AppColors.greenDark,
                              )),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      );

  Widget _logoutButton(BuildContext context) => IconButton(
        tooltip:  'Cerrar sesión',
        icon:     const Icon(Icons.logout_outlined),
        onPressed: () async {
          await context.read<AuthViewModel>().logout();
          if (!context.mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
        },
      );
}