import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserProfileBanner extends StatelessWidget {
  final String banner;

  const UserProfileBanner({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: shadTheme.colorScheme.secondary.withOpacity(0.1),
        image: banner.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(banner),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: banner.isEmpty
          ? Center(
              child: Text(
                'No Banner',
                style: TextStyle(
                  color: shadTheme.colorScheme.foreground,
                ),
              ),
            )
          : null,
    );
  }
}
