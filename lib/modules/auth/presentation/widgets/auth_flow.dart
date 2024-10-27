import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';

class AuthFlow extends StatelessWidget {
  final String buttonText;
  final void Function() onPressed;
  final String title;
  const AuthFlow({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(),
          ),
          Text(
            buttonText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ShadColors.kSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
