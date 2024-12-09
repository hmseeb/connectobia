import 'package:connectobia/common/models/influencers.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/featured_image.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/image_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeaturedListings extends StatefulWidget {
  const FeaturedListings({super.key});

  @override
  State<FeaturedListings> createState() => _FeaturedListingsState();
}

class _FeaturedListingsState extends State<FeaturedListings> {
  late final ShadThemeData theme = ShadTheme.of(context);
  Influencers? influencers;
  int itemsCount = 10;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandDashboardBloc, BrandDashboardState>(
      listener: (context, state) {
        if (state is BrandDashboardLoadedInflueners) {
          influencers = state.influencers;
          itemsCount = influencers!.items.length;
        }
      },
      builder: (context, state) {
        return Skeletonizer(
          enabled: state is BrandDashboardLoadingInflueners,
          child: Column(
            children: List.generate(
              state is BrandDashboardLoadedInflueners ? itemsCount : 10,
              (index) {
                return GestureDetector(
                  onTap: () {
                    if (state is BrandDashboardLoadedInflueners) {
                      final id = influencers!.items[index].id;
                      BlocProvider.of<InfluencerProfileBloc>(context)
                          .add(InfluencerProfileLoad(id));
                      Navigator.pushNamed(context, '/influencerProfile',
                          arguments: {
                            'userId': id,
                          });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Center(
                              child: state is BrandDashboardLoadedInflueners
                                  ? FeatureImage(
                                      image: influencers!.items[index].banner!,
                                      id: influencers!.items[index].id,
                                      collectionId: influencers!
                                          .items[index].collectionId,
                                    )
                                  : SizedBox()),
                          state is BrandDashboardLoadedInflueners
                              ? FeatureImageInfo(
                                  state: state, user: influencers!.items[index])
                              : const SizedBox(),
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
          ),
        );
      },
    );
  }

  // int getTotalInfluencers() {
  //   int length = influencers!.totalItems;
  //   // for (var element in influencers) {
  //   //   length += element.items.length;
  //   // }
  //   return length;
  // }
}
