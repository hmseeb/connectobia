import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';

/// A function that returns a transparent app bar
///
/// This function is used to return a transparent app bar that is used throughout
/// the application. This function is used to maintain a consistent transparent app bar
/// throughout the application.
///
/// {@category Widgets}
AppBar transparentAppBar(String? title,
    {List<Widget>? actions, required BuildContext context}) {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  return AppBar(
    elevation: 0,
    backgroundColor:
        brightness == Brightness.light ? ShadColors.light : ShadColors.dark,
    title: Text(title ?? ''),
    actions: actions,
  );
}
