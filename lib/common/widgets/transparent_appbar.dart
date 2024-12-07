import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A function that returns a transparent app bar
///
/// This function is used to return a transparent app bar that is used throughout
/// the application. This function is used to maintain a consistent transparent app bar
/// throughout the application.
///
/// {@category Widgets}
AppBar transparentAppBar(String? title,
    {List<Widget>? actions, required BuildContext context}) {
  final shadTheme = ShadTheme.of(context);
  return AppBar(
    elevation: 0,
    title: Text(title ?? ''),
    backgroundColor: shadTheme.brightness == Brightness.dark
        ? ShadColors.dark
        : ShadColors.light,
    actions: actions,
  );
}
