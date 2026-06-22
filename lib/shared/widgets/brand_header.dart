import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header de marca SUMS/IMSS-Bienestar.
/// La firma visual: franja verde izquierda + badge institucional.
class BrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;
  final Color? accentColor;

  const BrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.compact = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.green;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo con badge de estado
        Row(
          children: [
            Image.asset(
              'assets/images/imss-bienestar-logo.png',
              width: compact ? 180 : 240,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            if (!compact)
              _StatusBadge(color: accent),
          ],
        ),
        SizedBox(height: compact ? 16 : 24),
        // Borde acento izquierdo — firma única del diseño
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: (compact
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.headlineMedium)
                          ?.copyWith(color: AppColors.greenDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  const _StatusBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color:  color,
              shape:  BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'En línea',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de sección con borde izquierdo de color — firma del diseño.
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Borde de color izquierdo — firma del diseño
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: accentColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.greenDark,
                                        fontWeight: FontWeight.w800,
                                      )),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(subtitle!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.muted)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (children.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...children,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}