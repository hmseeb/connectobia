import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../theme/colors.dart';

/// A function that returns a transparent app bar
///
/// This function is used to return a transparent app bar that is used throughout
/// the application. This function is used to maintain a consistent transparent app bar
/// throughout the application.
///
/// {@category Widgets}
AppBar transparentAppBar(
  String? title, {
  List<Widget>? actions,
  Widget? leading,
  centerTitle = true,
  required BuildContext context,
}) {
  final Brightness brightness = ShadTheme.of(context).brightness;
  return AppBar(
    elevation: 0,
    centerTitle: centerTitle,
    backgroundColor:
        brightness == Brightness.light ? ShadColors.light : ShadColors.dark,
    title: Text(title ?? ''),
    actions: actions,
    leading: leading,
  );
}
