// ────────────────────────────────────────────────────────────────────────────
// home_medico_page.dart
// ────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeMedicoPage extends StatelessWidget {
  const HomeMedicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>().session?.user.nombreUsuario ?? 'médico';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _RolHeader(
                userName: 'Dr. $userName',
                rolLabel: 'Médico IMSS-Bienestar',
                rolColor: AppColors.rolMedico,
                icon:     Icons.medical_services_outlined,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionLabel(text: 'Módulos clínicos'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverList.separated(
                itemCount: _modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final m = _modules[i];
                  return _ModuleRow(
                    icon: m.icon, title: m.title,
                    subtitle: m.subtitle, color: m.color,
                  );
                },
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  static const _modules = [
    _Module(Icons.vaccines_outlined, 'Esquemas de vacunación', 'Registra y consulta inmunizaciones por persona.', AppColors.green),
    _Module(Icons.people_alt_outlined, 'Personas', 'Datos personales y perfil de salud de cada integrante.', AppColors.greenDark),
    _Module(Icons.health_and_safety_outlined, 'Salud preventiva', 'Tamizajes, atención de embarazo y seguimiento.', AppColors.burgundy),
    _Module(Icons.monitor_heart_outlined, 'Enfermedades crónicas', 'Hipertensión, diabetes y seguimiento longitudinal.', AppColors.terracota),
  ];

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: Row(
          children: [
            Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.rolMedico, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('Médico'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
          const SizedBox(width: 4),
        ],
      );
}

class _Module {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Module(this.icon, this.title, this.subtitle, this.color);
}

class _ModuleRow extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final Color    color;
  const _ModuleRow({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(color: AppColors.line),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.greenDark)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.subtle, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Shared widgets reutilizados aquí también ────────────────────────────────────

class _RolHeader extends StatelessWidget {
  final String userName, rolLabel;
  final Color  rolColor;
  final IconData icon;
  const _RolHeader({required this.userName, required this.rolLabel, required this.rolColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greenDark,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: rolColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $userName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: rolColor.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                  child: Text(rolLabel, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1.0),
      );
}