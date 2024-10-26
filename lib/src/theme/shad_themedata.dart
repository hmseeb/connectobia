import 'dart:ui';

import 'package:connectobia/src/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

ShadThemeData shadThemeData(bool isDarkMode) {
  return ShadThemeData(
    textTheme: ShadTextTheme(
      family: 'VarelaRound',
    ),
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: isDarkMode
        ? const ShadSlateColorScheme.dark(
            primary: ShadColors.kPrimary,
            secondary: ShadColors.kSecondary,
            foreground: ShadColors.kBackground,
            background: ShadColors.kForeground,
          )
        : const ShadSlateColorScheme.light(
            primary: ShadColors.kPrimary,
            secondary: ShadColors.kSecondary,
            foreground: ShadColors.kForeground,
            background: ShadColors.kBackground,
          ),
  );
}
