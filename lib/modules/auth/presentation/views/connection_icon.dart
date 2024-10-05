import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';

class ConnectionIcon extends StatelessWidget {
  const ConnectionIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Hero(
      tag: 'logo',
      child: Icon(
        Icons.link,
        color: Pellet.kSecondary,
      ),
    );
  }
}
