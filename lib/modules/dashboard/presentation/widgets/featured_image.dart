import 'package:connectobia/common/constants/avatar.dart';
import 'package:flutter/material.dart';

class FeatureImage extends StatelessWidget {
  final String image;
  final String id;
  final String collectionId;

  const FeatureImage({
    super.key,
    required this.image,
    required this.id,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      image.isEmpty
          ? Avatar.getBannerPlaceholder()
          : Avatar.getUserImage(
              id: id, image: image, collectionId: collectionId),
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
    );
  }
}
