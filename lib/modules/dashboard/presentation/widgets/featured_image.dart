import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FeatureImage extends StatelessWidget {
  const FeatureImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: 'https://via.assets.so/img.jpg?w=400&h=300&tc=#A9A9A9&bg=grey',
      width: 400,
      height: 300,
      fit: BoxFit.cover,
    );
  }
}
