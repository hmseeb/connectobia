import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final Widget? leading;

  const InfoCard({
    super.key,
    required this.text,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(text, style: ShadTheme.of(context).textTheme.p),
          ),
        ],
      ),
    );
  }
}
