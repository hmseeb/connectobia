import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrimaryAuthButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final void Function() onPressed;
  const PrimaryAuthButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // get shad theme data
    final shadTheme = ShadTheme.of(context);
    return SizedBox(
      width: 350,
      child: ShadButton(
        onPressed: onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: shadTheme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ),
              )
            : Text(text),
      ),
    );
  }
}
