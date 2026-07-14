import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';

/// Theme toggle button widget (40×40dp circular)
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colors = context.colors;

    return Tooltip(
      message: 'Switch to ${themeMode == ThemeMode.light ? 'dark' : 'light'} theme',
      child: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          icon: Icon(
            themeMode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode,
            size: 20,
          ),
          color: colors.foreground,
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
        ),
      ),
    );
  }
}
