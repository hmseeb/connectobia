import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

/// A widget that displays the tagline of the application
/// This widget is used to display the tagline of the application. It is
///
/// {@category Widgets}
class Tagline extends StatelessWidget {
  final String tagline;
  const Tagline(
    this.tagline, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      tagline.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: ShadColors.primary,
      ),
    );
  }
}
