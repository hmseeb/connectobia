import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      children: [
        Text(
          'By creating an account, you agree to our ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          'terms of service',
          style: TextStyle(
            fontSize: 12,
            color: Pellet.kSecondary,
          ),
        ),
        Text(
          'and ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          'privacy policy',
          style: TextStyle(
            fontSize: 12,
            color: Pellet.kSecondary,
          ),
        ),
      ],
    );
  }
}
