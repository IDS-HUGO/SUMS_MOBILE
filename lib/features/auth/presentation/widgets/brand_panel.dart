import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class BrandPanel extends ConsumerWidget {
  const BrandPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
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

class MobileLoginHeader extends ConsumerWidget {
  const MobileLoginHeader({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(40, 15, 40, 32),
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

class _InfoBadge extends ConsumerWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
