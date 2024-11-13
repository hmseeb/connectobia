import "package:flutter/material.dart";

class ColorFamily {
  final Color color;

  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  List<ExtendedColor> get extendedColors => [];

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff9f9),
      surfaceTint: Color(0xffffb3ae),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb9b5),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9f9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffebc1be),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffffaf7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe6c690),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a1111),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffff9f9),
      outline: Color(0xffdcc6c4),
      outlineVariant: Color(0xffdcc6c4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedd),
      inversePrimary: Color(0xff4e1716),
      primaryFixed: Color(0xffffe0dd),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb9b5),
      onPrimaryFixedVariant: Color(0xff330405),
      secondaryFixed: Color(0xffffe0dd),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffebc1be),
      onSecondaryFixedVariant: Color(0xff26100f),
      tertiaryFixed: Color(0xffffe3b6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe6c690),
      onTertiaryFixedVariant: Color(0xff201400),
      surfaceDim: Color(0xff1a1111),
      surfaceBright: Color(0xff423736),
      surfaceContainerLowest: Color(0xff140c0c),
      surfaceContainerLow: Color(0xff231919),
      surfaceContainer: Color(0xff271d1d),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb9b5),
      surfaceTint: Color(0xffffb3ae),
      onPrimary: Color(0xff330405),
      primaryContainer: Color(0xffcb7b76),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffebc1be),
      onSecondary: Color(0xff26100f),
      secondaryContainer: Color(0xffad8885),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe6c690),
      onTertiary: Color(0xff201400),
      tertiaryContainer: Color(0xffa98d5b),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff330404),
      errorContainer: Color(0xffcc7b72),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a1111),
      onSurface: Color(0xfffff9f9),
      onSurfaceVariant: Color(0xffdcc6c4),
      outline: Color(0xffb39e9c),
      outlineVariant: Color(0xff927f7d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedd),
      inversePrimary: Color(0xff743432),
      primaryFixed: Color(0xffffdad7),
      onPrimaryFixed: Color(0xff2c0103),
      primaryFixedDim: Color(0xffffb3ae),
      onPrimaryFixedVariant: Color(0xff5e2321),
      secondaryFixed: Color(0xffffdad7),
      onSecondaryFixed: Color(0xff200b0a),
      secondaryFixedDim: Color(0xffe7bdb9),
      onSecondaryFixedVariant: Color(0xff4b2f2d),
      tertiaryFixed: Color(0xffffdea7),
      onTertiaryFixed: Color(0xff1a0f00),
      tertiaryFixedDim: Color(0xffe2c28c),
      onTertiaryFixedVariant: Color(0xff473309),
      surfaceDim: Color(0xff1a1111),
      surfaceBright: Color(0xff423736),
      surfaceContainerLowest: Color(0xff140c0c),
      surfaceContainerLow: Color(0xff231919),
      surfaceContainer: Color(0xff271d1d),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb3ae),
      surfaceTint: Color(0xffffb3ae),
      onPrimary: Color(0xff571d1c),
      primaryContainer: Color(0xff733331),
      onPrimaryContainer: Color(0xffffdad7),
      secondary: Color(0xffe7bdb9),
      onSecondary: Color(0xff442928),
      secondaryContainer: Color(0xff5d3f3d),
      onSecondaryContainer: Color(0xffffdad7),
      tertiary: Color(0xffe2c28c),
      onTertiary: Color(0xff402d04),
      tertiaryContainer: Color(0xff594319),
      onTertiaryContainer: Color(0xffffdea7),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73332d),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a1111),
      onSurface: Color(0xfff1dedd),
      onSurfaceVariant: Color(0xffd8c2c0),
      outline: Color(0xffa08c8b),
      outlineVariant: Color(0xff534342),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedd),
      inversePrimary: Color(0xff904a46),
      primaryFixed: Color(0xffffdad7),
      onPrimaryFixed: Color(0xff3b0809),
      primaryFixedDim: Color(0xffffb3ae),
      onPrimaryFixedVariant: Color(0xff733331),
      secondaryFixed: Color(0xffffdad7),
      onSecondaryFixed: Color(0xff2c1514),
      secondaryFixedDim: Color(0xffe7bdb9),
      onSecondaryFixedVariant: Color(0xff5d3f3d),
      tertiaryFixed: Color(0xffffdea7),
      onTertiaryFixed: Color(0xff271900),
      tertiaryFixedDim: Color(0xffe2c28c),
      onTertiaryFixedVariant: Color(0xff594319),
      surfaceDim: Color(0xff1a1111),
      surfaceBright: Color(0xff423736),
      surfaceContainerLowest: Color(0xff140c0c),
      surfaceContainerLow: Color(0xff231919),
      surfaceContainer: Color(0xff271d1d),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff440f0f),
      surfaceTint: Color(0xff904a46),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6e2f2d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff341b1a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff593b39),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2f1f00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff553f15),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff44100c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff6e302a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff2e2120),
      outline: Color(0xff4e3f3e),
      outlineVariant: Color(0xff4e3f3e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e2d),
      inversePrimary: Color(0xffffe7e4),
      primaryFixed: Color(0xff6e2f2d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff521a19),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff593b39),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff402624),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff553f15),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3c2902),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedd),
    );
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6e2f2d),
      surfaceTint: Color(0xff904a46),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffaa5f5b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff593b39),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff8f6c69),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff553f15),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8b7142),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff6e302a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffaa6058),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff231919),
      onSurfaceVariant: Color(0xff4e3f3e),
      outline: Color(0xff6c5b5a),
      outlineVariant: Color(0xff897675),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e2d),
      inversePrimary: Color(0xffffb3ae),
      primaryFixed: Color(0xffaa5f5b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff8d4844),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff8f6c69),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff745452),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8b7142),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff70582c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedd),
    );
  }

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff904a46),
      surfaceTint: Color(0xff904a46),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad7),
      onPrimaryContainer: Color(0xff3b0809),
      secondary: Color(0xff775654),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad7),
      onSecondaryContainer: Color(0xff2c1514),
      tertiary: Color(0xff735b2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdea7),
      onTertiaryContainer: Color(0xff271900),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff3b0907),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff231919),
      onSurfaceVariant: Color(0xff534342),
      outline: Color(0xff857371),
      outlineVariant: Color(0xffd8c2c0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e2d),
      inversePrimary: Color(0xffffb3ae),
      primaryFixed: Color(0xffffdad7),
      onPrimaryFixed: Color(0xff3b0809),
      primaryFixedDim: Color(0xffffb3ae),
      onPrimaryFixedVariant: Color(0xff733331),
      secondaryFixed: Color(0xffffdad7),
      onSecondaryFixed: Color(0xff2c1514),
      secondaryFixedDim: Color(0xffe7bdb9),
      onSecondaryFixedVariant: Color(0xff5d3f3d),
      tertiaryFixed: Color(0xffffdea7),
      onTertiaryFixed: Color(0xff271900),
      tertiaryFixedDim: Color(0xffe2c28c),
      onTertiaryFixedVariant: Color(0xff594319),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedd),
    );
  }
}
