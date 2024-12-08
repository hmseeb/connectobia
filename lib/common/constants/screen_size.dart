// responsive spacing constants
import 'package:flutter/material.dart';

/// A class that holds the spacing constants for the application
///
/// This class is used to store the spacing constants that are used throughout the
/// application. This class is used to maintain a consistent spacing scheme
/// throughout the application.
///
/// {@category Constants}
class ScreenSize {
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height / 100;
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 100;
}
