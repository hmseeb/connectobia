import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserProfileAvatar extends StatelessWidget {
  final String avatar;
  final VoidCallback onEdit;

  const UserProfileAvatar({
    super.key,
    required this.avatar,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          backgroundColor: shadTheme.colorScheme.secondary.withOpacity(0.2),
          child: avatar.isEmpty
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: shadTheme.colorScheme.foreground,
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: shadTheme.colorScheme.secondary,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: 16,
                color: shadTheme.colorScheme.foreground,
              ),
              onPressed: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}
