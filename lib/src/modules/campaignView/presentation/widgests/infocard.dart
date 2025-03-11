import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final Widget? leading;
  final bool isMultiline; // Supports multi-line content

  const InfoCard({
    super.key,
    required this.text,
    this.leading,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Adjust opacity here
        borderRadius: BorderRadius.circular(12), // Match ShadCard's look
      ),
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
