import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/screens.dart';

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
              Navigator.pushNamed(context, editProfileScreen);
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
