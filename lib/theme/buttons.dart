import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrimaryAuthButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  const PrimaryAuthButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ShadButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
