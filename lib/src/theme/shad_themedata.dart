import 'dart:ui';

import 'package:connectobia/src/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

ShadThemeData shadThemeData(bool isDarkMode) {
  return ShadThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: isDarkMode
        ? const ShadSlateColorScheme.dark(
            primary: Pellet.kPrimary,
            secondary: Pellet.kSecondary,
            foreground: Pellet.kBackground,
            background: Pellet.kForeground,
          )
        : const ShadSlateColorScheme.light(
            primary: Pellet.kPrimary,
            secondary: Pellet.kSecondary,
            foreground: Pellet.kForeground,
            background: Pellet.kBackground,
          ),
  );
}
