import 'package:connectobia/src/globals/constants/path.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(AssetsPath.logo),
      color: Colors.redAccent,
      size: size,
    );
  }
}
