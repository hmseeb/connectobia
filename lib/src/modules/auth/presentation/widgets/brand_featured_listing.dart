import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../dashboard/brand/application/brand_dashboard/brand_dashboard_bloc.dart';
import '../../../dashboard/brand/presentation/widgets/featured_image.dart';
import '../../../dashboard/brand/presentation/widgets/heart_icon.dart';
import '../../../dashboard/brand/presentation/widgets/image_info.dart';
import '../../../dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';
import 'listings_placeholder.dart';

class BrandFeaturedListings extends StatefulWidget {
  const BrandFeaturedListings({super.key});

  @override
  State<BrandFeaturedListings> createState() => _BrandFeaturedListingsState();
}

class _BrandFeaturedListingsState extends State<BrandFeaturedListings> {
  late final ShadThemeData theme = ShadTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandDashboardBloc, BrandDashboardState>(
      builder: (context, state) {
        if (state is BrandDashboardLoadedInfluencers) {
          return Column(
            children: List.generate(
              state.influencers.totalItems,
              (index) {
                return GestureDetector(
                  onTap: () {
                    final id = state.influencers.items[index].profile;
                    BlocProvider.of<InfluencerProfileBloc>(context).add(
                        InfluencerProfileLoad(
                            profileId: id,
                            influencer: state.influencers.items[index]));
                    Navigator.pushNamed(context, profile, arguments: {
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
                            image: state.influencers.items[index].banner,
                            id: state.influencers.items[index].id,
                            collectionId:
                                state.influencers.items[index].collectionId,
                          )),
                          FeatureImageInfo(
                            title: state.influencers.items[index].fullName,
                            subTitle: state.influencers.items[index].industry,
                            connectedSocial:
                                state.influencers.items[index].connectedSocial,
                            avatar: state.influencers.items[index].avatar,
                            userId: state.influencers.items[index].id,
                            collectionId:
                                state.influencers.items[index].collectionId,
                          ),
                          // Add the heart icon for favorites
                          FeatureHeartIcon(
                            targetUserId: state.influencers.items[index].id,
                            targetUserType: 'influencers',
                            onToggle: (isFavorite) {
                              // Refresh the list if needed when toggling favorites
                              if (state.influencers.items.length == 1 &&
                                  !isFavorite) {
                                BlocProvider.of<BrandDashboardBloc>(context)
                                    .add(BrandDashboardLoadInfluencers());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Skeletonizer(
              enabled: state is BrandDashboardLoadingInfluencers,
              child: Column(
                children: [
                  ListingsPlaceHolder(),
                  SizedBox(height: 16),
                  ListingsPlaceHolder(),
                ],
              ));
        }
      },
    );
  }
}
