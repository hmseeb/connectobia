import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String heading;

  const HeadingText(
    this.heading, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      heading,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.start,
    );
  }
}
