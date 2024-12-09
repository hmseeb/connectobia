import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/dashboard/brand/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/views/edit_influencer_profile.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/views/featured_listing.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/widgets/bottom_navigation.dart';
import 'package:connectobia/modules/dashboard/common/views/appbar.dart';
import 'package:connectobia/modules/dashboard/common/views/drawer.dart';
import 'package:connectobia/modules/dashboard/common/views/popular_categories.dart';
import 'package:connectobia/modules/dashboard/common/widgets/section_title.dart';
import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandDashboard extends StatefulWidget {
  final Brand user;
  const BrandDashboard({super.key, required this.user});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  late Brand user = widget.user;
  late final List<String> _industries;
  late final influencerBloc = BlocProvider.of<BrandDashboardBloc>(context);
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
                    const SectionTitle('Featured Listings'),
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
    influencerBloc.add(BrandDashboardLoadInfluencers());
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
