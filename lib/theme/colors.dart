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
///    primaryColor: ShadColors.kPrimary,
///   backgroundColor: ShadColors.kBackground,
///  ),
/// home: MyHomePage(),
/// ),
/// );
/// }
/// ```
/// {@category Theme}
class ShadColors {
  static const Color kPrimary = Color(0xff212121);
  static const Color kDisabled = Colors.grey;
  static const Color kSecondary = Colors.redAccent;
  static const Color kBackground = Color(0xfffaf8f6);
  static const Color kForeground = Color(0xFF060b14);
  static const Color kDrawerBackground = Color(0xfffaf8f6);
}
