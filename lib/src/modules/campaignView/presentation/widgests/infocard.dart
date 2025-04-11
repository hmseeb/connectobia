import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final Widget? leading;
  final bool isMultiline; // New property to support multi-line content
  final double opacity; // New property to control opacity

  const InfoCard({
    super.key,
    required this.text,
    this.leading,
    this.isMultiline = false, // Default to false
    this.opacity = 1.0, // Default to fully opaque
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity, // Set the opacity value
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                text,
                style: ShadTheme.of(context).textTheme.p,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}