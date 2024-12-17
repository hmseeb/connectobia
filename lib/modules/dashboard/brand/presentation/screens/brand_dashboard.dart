import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../common/constants/industries.dart';
import '../../../../../theme/bloc/theme_bloc.dart';
import '../../../../auth/domain/model/brand.dart';
import '../../../../auth/presentation/views/brand_featured_listing.dart';
import '../../../common/views/appbar.dart';
import '../../../common/views/drawer.dart';
import '../../../common/views/popular_categories.dart';
import '../../../common/widgets/section_title.dart';
import '../../application/brand_dashboard/brand_dashboard_bloc.dart';
import '../widgets/bottom_navigation.dart';

class BrandDashboard extends StatefulWidget {
  final Brand user;
  const BrandDashboard({super.key, required this.user});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  late Brand user = widget.user;
  late final List<String> _industries;
  late final brightness = ShadTheme.of(context).brightness;
  final ScrollController scrollController = ScrollController();

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          endDrawer: CommonDrawer(
            name: user.brandName,
            email: user.email,
            collectionId: user.collectionId,
            avatar: '',
            userId: user.id,
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CommonAppBar(
                  userName: user.brandName,
                  searchPlaceholder: 'Search for influencers'),
            ],
            body: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Popular Categories'),
                    const SizedBox(height: 16),
                    PopularCategories(industries: _industries),
                    const SectionTitle('Featured Influencers'),
                    const SizedBox(height: 16),
                    BlocBuilder<BrandDashboardBloc, BrandDashboardState>(
                      builder: (context, state) {
                        if (state is BrandDashboardLoadedInfluencers) {
                          return BrandFeaturedListings(
                            itemsCount: state.influencers.items.length,
                            influencers: state.influencers,
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: buildBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            state: state,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController
        .removeListener(_scrollListener); // Properly remove the listener
    scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  List<String> getSortedIndustries() {
    final industriesList =
        IndustryList.industries.entries.map((e) => e.value).toList();
    // return sorted the industries alphabetically
    industriesList.sort();
    industriesList.add('Others');
    return industriesList;
  }

  @override
  void initState() {
    super.initState();
    _industries = getSortedIndustries();
    scrollController.addListener(_scrollListener); // Pass the function directly
  }

  _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // TODO: Load more influencers
    }
  }
}
