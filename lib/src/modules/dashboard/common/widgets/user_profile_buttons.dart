import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfileButtons extends StatelessWidget {
  const ProfileButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ShadButton(
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
            child: const Text('Edit Profile'),
          ),
        ),
        Expanded(
          child: ShadButton.outline(
            onPressed: () {
              // Add your settings logic here
            },
            child: const Text('Settings'),
          ),
        ),
      ],
    );
  }
}
