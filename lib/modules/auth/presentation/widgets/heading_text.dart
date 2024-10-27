import 'package:flutter/material.dart';

/// A widget that displays a heading text
///
/// This widget is used to display a heading text in the application. It is
/// used to display a heading text in the application.
///
/// {@category Widgets}
class HeadingText extends StatelessWidget {
  final String heading;
  const HeadingText(
    this.heading, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Text(
        heading,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
