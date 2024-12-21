import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../shared/application/theme/theme_bloc.dart';
import 'colors.dart';

/// A class that holds the theme data for the application
///
/// This class is used to store the theme data that is used throughout the
/// application. This class is used to maintain a consistent theme
/// throughout the application.
///
/// {@category Theme}
ShadThemeData shadThemeData(ThemeState state) {
  return ShadThemeData(
    textTheme: ShadTextTheme(
      family: GoogleFonts.varelaRound().fontFamily,
    ),
    brightness: state is DarkTheme ? Brightness.dark : Brightness.light,
    colorScheme: state is DarkTheme
        ? const ShadSlateColorScheme.dark(
            secondary: ShadColors.primary,
            foreground: ShadColors.light,
            background: ShadColors.dark,
          )
        : const ShadSlateColorScheme.light(
            secondary: ShadColors.primary,
            foreground: ShadColors.dark,
            background: ShadColors.light,
          ),
  );
}
