import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';

class MineriaMenuPage extends StatelessWidget {
  const MineriaMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Minería'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(
                title: 'Motor de Inteligencia',
                subtitle: 'Búsqueda avanzada y análisis de riesgo familiar.',
                compact: true,
                accentColor: AppColors.rolAnalista,
              ),
              const SizedBox(height: 32),
              
              _MenuCard(
                title: 'Buscador de Casos',
                subtitle: 'Consultas en lenguaje natural sobre las notas médicas y familiares.',
                icon: Icons.search_rounded,
                color: AppColors.rolAnalista,
                onTap: () => Navigator.pushNamed(context, '/mineria/buscador'),
              ),
              
              const SizedBox(height: 16),
              
              _MenuCard(
                title: 'Riesgo Familiar',
                subtitle: 'Identificación de familias con alta probabilidad de vulnerabilidad.',
                icon: Icons.priority_high_rounded,
                color: AppColors.terracota,
                onTap: () => Navigator.pushNamed(context, '/mineria/riesgo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}
