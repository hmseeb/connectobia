import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../common/constants/industries.dart';
import '../../../../../theme/bloc/theme_bloc.dart';
import '../../../../auth/domain/model/influencer.dart';
import '../../../common/views/appbar.dart';
import '../../../common/views/drawer.dart';
import '../../../common/views/popular_categories.dart';
import '../../../common/widgets/section_title.dart';
import '../../../influencer/application/influencer_dashboard/influencer_dashboard_bloc.dart';
import '../../../influencer/presentation/views/influencer_featured_listings.dart';
import '../views/edit_influencer_profile.dart';
import '../widgets/bottom_navigation.dart';

class InfluencerDashboard extends StatefulWidget {
  final Influencer user;
  const InfluencerDashboard({super.key, required this.user});

  @override
  State<InfluencerDashboard> createState() => _InfluencerDashboardState();
}

class _InfluencerDashboardState extends State<InfluencerDashboard> {
  late Influencer user = widget.user;
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
            name: user.fullName,
            email: user.email,
            collectionId: user.collectionId,
            avatar: '',
            userId: user.id,
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CommonAppBar(
                  userName: user.fullName,
                  searchPlaceholder: 'Search for Brands'),
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
                    const SectionTitle('Featured Brands'),
                    const SizedBox(height: 16),
                    BlocBuilder<InfluencerDashboardBloc,
                        InfluencerDashboardState>(
                      builder: (context, state) {
                        if (state is InfluencerDashboardLoadedBrands) {
                          return InfluencerFeaturedListings(
                            itemsCount: state.brands.items.length,
                            brands: state.brands,
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

  Future<void> _displayEditInfluencerProfile(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final influencerParam = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditInfluencerProfile(),
      ),
    );
    if (influencerParam == null) return;
    setState(() {
      user = influencerParam;
    });
  }

  Future<void> _displayEditUserSettings(BuildContext context) async {
    assert(false, 'Not implemented');
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    // final userParam = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => InfluencerSettingSheet(
    //       user: user,
    //     ),
    //   ),
    // );
    // if (userParam == null) return;
    // setState(() {
    //   user = userParam;
    // });
  }

  _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // TODO: Load more influencers
    }
  }
}
