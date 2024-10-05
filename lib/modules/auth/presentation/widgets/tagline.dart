import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';

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
        color: Pellet.kSecondary,
      ),
    );
  }
}
