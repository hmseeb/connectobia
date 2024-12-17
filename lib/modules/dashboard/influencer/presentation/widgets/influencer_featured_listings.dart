import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../shared/domain/models/brands.dart';
import '../../../brand/presentation/widgets/featured_image.dart';
import '../../../brand/presentation/widgets/image_info.dart';
import '../../../common/application/brand_profile/brand_profile_bloc.dart';

class InfluencerFeaturedListings extends StatefulWidget {
  final int itemsCount;
  final Brands brands;
  const InfluencerFeaturedListings(
      {super.key, required this.itemsCount, required this.brands});

  @override
  State<InfluencerFeaturedListings> createState() =>
      _InfluencerFeaturedListingsState();
}

class _InfluencerFeaturedListingsState
    extends State<InfluencerFeaturedListings> {
  late final ShadThemeData theme = ShadTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.itemsCount,
        (index) {
          return GestureDetector(
            onTap: () {
              final id = widget.brands.items[index].profile;
              BlocProvider.of<BrandProfileBloc>(context).add(LoadBrandProfile(
                  profileId: id, brand: widget.brands.items[index]));
              Navigator.pushNamed(context, '/profile', arguments: {
                'profileId': id,
                'self': false,
                'profileType': 'brands'
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Center(
                        child: FeatureImage(
                      image: widget.brands.items[index].banner,
                      id: widget.brands.items[index].id,
                      collectionId: widget.brands.items[index].collectionId,
                    )),
                    FeatureImageInfo(
                      title: widget.brands.items[index].brandName,
                      subTitle: widget.brands.items[index].industry,
                      connectedSocial: false,
                      avatar: widget.brands.items[index].avatar,
                      userId: widget.brands.items[index].id,
                      collectionId: widget.brands.items[index].collectionId,
                    )
                    // Favorite button
                    // Add heart icon after implementing the feature
                    // const FeatureHeartIcon(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

  // int getTotalBrands() {
  //   int length = brands!.totalItems;
  //   // for (var element in brands) {
  //   //   length += element.items.length;
  //   // }
  //   return length;
  // }

