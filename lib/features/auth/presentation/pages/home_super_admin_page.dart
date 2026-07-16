import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_admin_page.dart'; // Reutilizamos componentes visuales de Admin

class HomeSuperAdminPage extends StatelessWidget {
  const HomeSuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'Super Admin';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xff1a237e), // Color distintivo Super Admin
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $userName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Super Administrador',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sección: Control Total
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: const Text(
                  'CONTROL TOTAL DEL SISTEMA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _ActionCard(
                    icon:    Icons.admin_panel_settings,
                    label:   'Gestión Admin',
                    detail:  'Control de administradores',
                    color:   const Color(0xff1a237e),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                  ),
                  _ActionCard(
                    icon:    Icons.analytics_outlined,
                    label:   'Minería',
                    detail:  'Motor de búsqueda y riesgo',
                    color:   AppColors.rolAnalista,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mineriaMenu),
                  ),
                  _ActionCard(
                    icon:    Icons.settings_applications,
                    label:   'Sistema',
                    detail:  'Configuración crítica',
                    color:   AppColors.terracota,
                    onTap: () {},
                  ),
                  _ActionCard(
                    icon:    Icons.history_edu,
                    label:   'Auditoría',
                    detail:  'Logs de movimientos',
                    color:   AppColors.gold,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: const Color(0xff1a237e),
        title: const Text('Super Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
        ],
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   detail;
  final Color    color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(detail, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
