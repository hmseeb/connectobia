import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/screens.dart';

class ProfileButtons extends StatelessWidget {
  final dynamic user;

  const ProfileButtons({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ShadButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                editProfileScreen,
                arguments: {'user': user},
              );
            },
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }
}
