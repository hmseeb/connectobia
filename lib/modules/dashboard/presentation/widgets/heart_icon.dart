import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FeatureHeartIcon extends StatelessWidget {
  final ShadThemeData theme;

  const FeatureHeartIcon({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: CircleAvatar(
        backgroundColor:
            theme.brightness == Brightness.light ? Colors.white : Colors.black,
        child: IconButton(
          icon: Icon(
            LucideIcons.heart,
            color: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
