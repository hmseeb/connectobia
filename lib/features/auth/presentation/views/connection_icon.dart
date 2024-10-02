import 'package:flutter/material.dart';

class ConnectionIcon extends StatelessWidget {
  const ConnectionIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationZ(0.1),
      child: const Icon(
        Icons.link,
        color: Colors.redAccent,
      ),
    );
  }
}
