import 'package:connectobia/globals/constants/avatar.dart';
import 'package:flutter/material.dart';

class FeatureImage extends StatelessWidget {
  final String image;
  final String id;
  const FeatureImage({
    super.key,
    required this.image,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      image.isEmpty
          ? Avatar.getBannerPlaceholder()
          : Avatar.getUserImage(id: id, image: image),
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
    );
  }
}
