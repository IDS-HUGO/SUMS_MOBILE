import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_mode_controller.dart';

class ThemeModeMenuButton extends ConsumerWidget {
  const ThemeModeMenuButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Cambiar tema',
      icon: Icon(_iconFor(mode)),
      initialValue: mode,
      onSelected: (selected) =>
          ref.read(themeModeProvider.notifier).setThemeMode(selected),
      itemBuilder: (context) => [
        _item(ThemeMode.light, Icons.light_mode_outlined, 'Claro'),
        _item(ThemeMode.dark, Icons.dark_mode_outlined, 'Oscuro'),
        _item(ThemeMode.system, Icons.brightness_auto_outlined, 'Sistema'),
      ],
    );
  }

  PopupMenuItem<ThemeMode> _item(ThemeMode mode, IconData icon, String label) {
    return PopupMenuItem<ThemeMode>(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }
}
