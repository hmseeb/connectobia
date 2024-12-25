import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    Brightness brightness = ShadTheme.of(context).brightness;
    if (image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: Avatar.getUserImage(
            recordId: id, image: image, collectionId: collectionId),
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: double.infinity,
        height: 300,
        color: brightness == Brightness.dark
            ? ShadColors.darkForeground
            : ShadColors.lightForeground,
      );
    }
  }
}
