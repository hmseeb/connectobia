import 'dart:ui';

import 'package:connectobia/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A class that holds the theme data for the application
///
/// This class is used to store the theme data that is used throughout the
/// application. This class is used to maintain a consistent theme
/// throughout the application.
///
/// {@category Theme}
ShadThemeData shadThemeData(bool isDarkMode) {
  return ShadThemeData(
    textTheme: ShadTextTheme(
      family: GoogleFonts.varelaRound().fontFamily,
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