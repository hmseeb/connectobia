import 'package:connectobia/common/models/influencer.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/featured_image.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/heart_icon.dart';
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
  late List<Influencers> influencers = [];
  late final ShadThemeData theme = ShadTheme.of(context);
  int page = 0;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandDashboardBloc, BrandDashboardState>(
      listener: (context, state) {
        if (state is BrandDashboardLoadedInflueners) {
          influencers.add(state.influencers);
        }
      },
      builder: (context, state) {
        return Skeletonizer(
          enabled: state is BrandDashboardLoadingInflueners,
          child: Column(
            children: List.generate(
              state is BrandDashboardLoadedInflueners
                  ? getTotalInfluencers()
                  : 10,
              (index) {
                if (index == 20) page++;
                return GestureDetector(
                  onTap: () {
                    if (state is BrandDashboardLoadedInflueners) {
                      final id = influencers[page].items[index].id;
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
                            child: FeatureImage(image: '', id: ''),
                          ),
                          state is BrandDashboardLoadedInflueners
                              ? FeatureImageInfo(
                                  state: state,
                                  user: influencers[page].items[index]
                                      as Influencer,
                                )
                              : const SizedBox(),
                          // Favorite button
                          const FeatureHeartIcon(),
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

  int getTotalInfluencers() {
    int length = 0;
    for (var element in influencers) {
      length += element.items.length;
    }
    return length;
  }
}
