import 'package:flutter/material.dart';

import '../../data/constants/assets.dart';

/// A class that holds the logo widget
///
/// This class is used to hold the logo widget that is used throughout the
/// application. This class is used to maintain a consistent logo widget
/// throughout the application.
///
/// {@category Widgets}
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
