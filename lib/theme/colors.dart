import 'package:flutter/material.dart';

/// A class that holds the color constants for the application
///
/// This class is used to store the color constants that are used throughout the
/// application. This class is used to maintain a consistent color scheme
/// throughout the application.
///
/// Example:
/// ```dart
/// import 'package:connectobia/theme/colors.dart';
///
/// void main() {
///  runApp(
///   MaterialApp(
///    theme: ThemeData(
///    primaryColor: ShadColors.dark,
///   backgroundColor: ShadColors.light,
///  ),
/// home: MyHomePage(),
/// ),
/// );
/// }
/// ```
/// {@category Theme}
class ShadColors {
  static const Color disabled = Colors.grey;
  static const Color primary = Colors.redAccent;
  static const Color light = Color(0xfffaf8f6);
  static const Color lightForeground = Color(0xffEFF1F5);

  static const Color dark = Color(0xFF060b14);
  static const Color darkForeground = Colors.black;
}
