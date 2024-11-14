import 'package:connectobia/globals/constants/avatar.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/domain/user_list.dart';
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
  late List<UserList> influencers = [];
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Center(
                          child: FeatureImage(
                              image: state is BrandDashboardLoadedInflueners
                                  ? influencers[page].items[index].avatar
                                  : '',
                              id: state is BrandDashboardLoadedInflueners
                                  ? influencers[page].items[index].id
                                  : Avatar.getBannerPlaceholder()),
                        ),
                        state is BrandDashboardLoadedInflueners
                            ? FeatureImageInfo(
                                state: state,
                                user: influencers[page].items[index],
                              )
                            : const SizedBox(),
                        // Favorite button
                        FeatureHeartIcon(theme: theme),
                      ],
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
