import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../shared/data/constants/avatar.dart';

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
    return image.isNotEmpty
        ? Image.network(
            Avatar.getUserImage(
                userId: id, image: image, collectionId: collectionId),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          )
        : Skeleton.shade(
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
            ),
          );
  }
}
