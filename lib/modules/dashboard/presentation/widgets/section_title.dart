import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const SectionTitle(
    this.text, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // view all button
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'View all',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
