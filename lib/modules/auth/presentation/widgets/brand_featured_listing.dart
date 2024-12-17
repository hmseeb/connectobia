import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/domain/models/influencers.dart';
import '../../../dashboard/brand/presentation/widgets/featured_image.dart';
import '../../../dashboard/brand/presentation/widgets/image_info.dart';
import '../../../dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';

class BrandFeaturedListings extends StatefulWidget {
  final int itemsCount;
  final Influencers influencers;
  const BrandFeaturedListings(
      {super.key, required this.itemsCount, required this.influencers});

  @override
  State<BrandFeaturedListings> createState() => _BrandFeaturedListingsState();
}

class _BrandFeaturedListingsState extends State<BrandFeaturedListings> {
  late final ShadThemeData theme = ShadTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.itemsCount,
        (index) {
          return GestureDetector(
            onTap: () {
              final id = widget.influencers.items[index].profile;
              BlocProvider.of<InfluencerProfileBloc>(context).add(
                  InfluencerProfileLoad(
                      profileId: id,
                      influencer: widget.influencers.items[index]));
              Navigator.pushNamed(context, '/profile', arguments: {
                'profileId': id,
                'self': false,
                'profileType': 'influencers'
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
                      image: widget.influencers.items[index].banner,
                      id: widget.influencers.items[index].id,
                      collectionId:
                          widget.influencers.items[index].collectionId,
                    )),
                    FeatureImageInfo(
                      title: widget.influencers.items[index].fullName,
                      subTitle: widget.influencers.items[index].industry,
                      connectedSocial:
                          widget.influencers.items[index].connectedSocial,
                      avatar: widget.influencers.items[index].avatar,
                      userId: widget.influencers.items[index].id,
                      collectionId:
                          widget.influencers.items[index].collectionId,
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

  // int getTotalInfluencers() {
  //   int length = influencers!.totalItems;
  //   // for (var element in influencers) {
  //   //   length += element.items.length;
  //   // }
  //   return length;
  // }

