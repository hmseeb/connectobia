import 'package:connectobia/modules/dashboard/brand/presentation/widgets/featured_image.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/widgets/image_info.dart';
import 'package:flutter/material.dart';

class ListingsPlaceHolder extends StatelessWidget {
  const ListingsPlaceHolder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Center(
                child: FeatureImage(
              image: '',
              id: 'id',
              collectionId: 'collectionId',
            )),
            FeatureImageInfo(
              title: 'Full Name',
              subTitle: 'Industry',
              connectedSocial: true,
              avatar: '',
              userId: 'id',
              collectionId: 'collectionId',
            )
            // Favorite button
            // Add heart icon after implementing the feature
            // const FeatureHeartIcon(),
          ],
        ),
      ),
    );
  }
}
