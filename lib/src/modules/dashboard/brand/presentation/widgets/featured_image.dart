import 'package:cached_network_image/cached_network_image.dart';
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
    if (image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: Avatar.getUserImage(
            userId: id, image: image, collectionId: collectionId),
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      return Skeleton.shade(
        child: Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
        ),
      );
    }
  }
}
