import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/theme_mode_menu_button.dart';

class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  void _showPendingFeatureMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La función de $feature estará disponible en la próxima actualización.',
        ),
        backgroundColor: AppColors.muted,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final userName = auth.session?.user.nombreUsuario ?? 'administrador';

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Cabecera de rol
            SliverToBoxAdapter(
              child: _RolHeader(
                userName: userName,
                rolLabel: 'Administrador del sistema',
                rolColor: AppColors.rolAdmin,
                icon: Icons.admin_panel_settings_outlined,
              ),
            ),

            // Sección: gestión
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionLabel(text: 'Gestión del sistema'),
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
                  _AdminActionCard(
                    icon: Icons.people_outline,
                    label: 'Usuarios',
                    detail: 'Gestión de cuentas y roles',
                    color: AppColors.rolAdmin,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminUsers),
                  ),
                  _AdminActionCard(
                    icon: Icons.local_hospital_outlined,
                    label: 'Unidades',
                    detail: 'Unidades de salud registradas',
                    color: AppColors.green,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminUnidades),
                  ),
                  _AdminActionCard(
                    icon: Icons.dataset_outlined,
                    label: 'Catálogos',
                    detail: 'Tablas y valores de referencia',
                    color: AppColors.terracota,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminCatalogos),
                  ),
                  _AdminActionCard(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reportes',
                    detail: 'Análisis y exportación de datos',
                    color: AppColors.gold,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminReportes),
                  ),
                  _AdminActionCard(
                    icon: Icons.trending_up_outlined,
                    label: 'Productividad',
                    detail: 'Métricas por entrevistador',
                    color: AppColors.rolMedico,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productividadAdmin,
                    ),
                  ),
                  _AdminActionCard(
                    icon: Icons.document_scanner_outlined,
                    label: 'Escaneo de Cédulas',
                    detail: 'Captura automática desde PDF',
                    color: AppColors.ink,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminMineria),
                  ),
                  _AdminActionCard(
                    icon: Icons.travel_explore,
                    label: 'Búsqueda de Notas',
                    detail: 'Buscar en notas de visita',
                    color: AppColors.rolAnalista,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminBusqueda),
                  ),
                ],
              ),
            ),

            // Sección: acceso rápido
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionLabel(text: 'Acceso rápido'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _QuickLinkRow(
                      icon: Icons.assignment_outlined,
                      label: 'Cédulas',
                      color: AppColors.green,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminCedulas),
                    ),
                    const SizedBox(height: 8),
                    _QuickLinkRow(
                      icon: Icons.tune_outlined,
                      label: 'Configuración del sistema',
                      color: AppColors.muted,
                      onTap: () => _showPendingFeatureMessage(
                        context,
                        'Configuración del sistema',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) => AppBar(
    title: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.rolAdmin,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text('Administrador'),
      ],
    ),
    actions: [
      const ThemeModeMenuButton(),
      IconButton(
        tooltip: 'Cerrar sesión',
        icon: const Icon(Icons.logout_outlined),
        onPressed: () async {
          await ref.read(authViewModelProvider).logout();
          if (!context.mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
        },
      ),
      const SizedBox(width: 4),
    ],
  );
}

// ── Cabecera de rol (compartida) ──────────────────────────────────────────────

class _RolHeader extends ConsumerWidget {
  final String userName;
  final String rolLabel;
  final Color rolColor;
  final IconData icon;

  const _RolHeader({
    required this.userName,
    required this.rolLabel,
    required this.rolColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.greenDark,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rolColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: rolColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rolLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends ConsumerWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ── Tarjeta de acción admin ───────────────────────────────────────────────────

class _AdminActionCard extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final VoidCallback? onTap;

  const _AdminActionCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.greenLight : AppColors.greenDark;
    final mutedColor = isDark ? Colors.grey[400] : AppColors.muted;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      color: mutedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkRow extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickLinkRow({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkColor = isDark ? Colors.white : AppColors.ink;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: inkColor,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.subtle,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
