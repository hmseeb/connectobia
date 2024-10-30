import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/featured_image.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/heart_icon.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/image_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeaturedListings extends StatelessWidget {
  const FeaturedListings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return BlocConsumer<BrandDashboardBloc, BrandDashboardState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Skeletonizer(
          enabled: state is BrandDashboardLoadingInflueners,
          child: Column(
            children: List.generate(
              state is BrandDashboardLoadedInflueners
                  ? state.influencers.items.length
                  : 5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      const Center(
                        child: FeatureImage(),
                      ),
                      state is BrandDashboardLoadedInflueners
                          ? FeatureImageInfo(
                              state: state,
                              index: index,
                            )
                          : const SizedBox(),
                      // Favorite button
                      FeatureHeartIcon(theme: theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
