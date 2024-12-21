import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../auth/presentation/widgets/listings_placeholder.dart';
import '../../../brand/presentation/widgets/featured_image.dart';
import '../../../brand/presentation/widgets/image_info.dart';
import '../../../common/application/brand_profile/brand_profile_bloc.dart';
import '../../application/influencer_dashboard/influencer_dashboard_bloc.dart';

class InfluencerFeaturedListings extends StatefulWidget {
  const InfluencerFeaturedListings({super.key});

  @override
  State<InfluencerFeaturedListings> createState() =>
      _InfluencerFeaturedListingsState();
}

class _InfluencerFeaturedListingsState
    extends State<InfluencerFeaturedListings> {
  late final ShadThemeData theme = ShadTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfluencerDashboardBloc, InfluencerDashboardState>(
      builder: (context, state) {
        return state is InfluencerDashboardLoadedBrands
            ? Column(
                children: List.generate(
                  state.brands.totalItems,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        final id = state.brands.items[index].profile;
                        BlocProvider.of<BrandProfileBloc>(context).add(
                            LoadBrandProfile(
                                profileId: id,
                                brand: state.brands.items[index]));
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
                                image: state.brands.items[index].banner,
                                id: state.brands.items[index].id,
                                collectionId:
                                    state.brands.items[index].collectionId,
                              )),
                              FeatureImageInfo(
                                title: state.brands.items[index].brandName,
                                subTitle: state.brands.items[index].industry,
                                connectedSocial: false,
                                avatar: state.brands.items[index].avatar,
                                userId: state.brands.items[index].id,
                                collectionId:
                                    state.brands.items[index].collectionId,
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
              )
            : Skeletonizer(
                child: Column(
                children: [
                  ListingsPlaceHolder(),
                  SizedBox(height: 16),
                  ListingsPlaceHolder(),
                ],
              ));
      },
    );
  }
}
