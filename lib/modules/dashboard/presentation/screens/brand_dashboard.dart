import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/globals/constants/avatar.dart';
import 'package:connectobia/globals/constants/greetings.dart';
import 'package:connectobia/globals/constants/industries.dart';
import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/views/edit_profile.dart';
import 'package:connectobia/modules/dashboard/presentation/views/featured_listing.dart';
import 'package:connectobia/modules/dashboard/presentation/views/popular_categories.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/bottom_navigation.dart';
import 'package:connectobia/modules/dashboard/presentation/widgets/section_title.dart';
import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandDashboard extends StatefulWidget {
  final User user;
  const BrandDashboard({super.key, required this.user});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  late User user = widget.user;
  late final List<String> _industries;
  late final influencerBloc = BlocProvider.of<BrandDashboardBloc>(context);
  late final brightness = ShadTheme.of(context).brightness;

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final width = ScreenSize.width(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          endDrawer: profileDrawer(context),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                snap: true,
                floating: true,
                pinned: true,
                scrolledUnderElevation: 0,
                backgroundColor:
                    state is DarkTheme ? ShadColors.dark : ShadColors.light,
                centerTitle: false,
                // search field
                // add search field at bottom
                title: Text(Greetings.getGreeting(user.firstName)),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(69),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ShadInput(
                      placeholder: Text('Search for services or influencers'),
                      prefix: Icon(LucideIcons.search),
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        Avatar.getUserImage(
                          id: user.id,
                          image: user.avatar,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
            body: Center(
              child: SizedBox(
                width: width * 95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Popular Categories'),
                      const SizedBox(height: 16),
                      PopularCategories(industries: _industries),
                      const SectionTitle('Featured Listings'),
                      const SizedBox(height: 16),
                      const FeaturedListings(),
                    ],
                  ),
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
  }

  BlocBuilder<ThemeBloc, ThemeState> profileDrawer(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color:
                      state is DarkTheme ? ShadColors.dark : ShadColors.light,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            Avatar.getUserImage(
                              id: user.id,
                              image: user.avatar,
                            ),
                          ),
                        ),
                        // toggle theme button
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            state is DarkTheme
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                          ),
                          onPressed: () {
                            bool isDarkMode = state is DarkTheme;
                            isDarkMode = !isDarkMode;
                            BlocProvider.of<ThemeBloc>(context).add(
                              ThemeChanged(isDarkMode),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(
                        color: state is DarkTheme
                            ? ShadColors.light
                            : ShadColors.dark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: state is DarkTheme
                            ? ShadColors.light
                            : ShadColors.dark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(LucideIcons.userCog),
                    SizedBox(width: 16),
                    Text('Edit Profile'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateAndDisplaySelection(context);
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(
                      LucideIcons.logOut,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  showShadDialog(
                    context: context,
                    builder: (context) => ShadDialog.alert(
                      title: const Text('You\'ll be logged out immediately!'),
                      actions: [
                        ShadButton.outline(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ShadButton(
                          child: const Text('Confirm'),
                          onPressed: () async {
                            await AuthRepo.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/welcome',
                                (route) => false,
                              );
                            }
                            return Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final userParam = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileSheet(
          user: user,
        ),
      ),
    );
    if (userParam == null) return;
    setState(() {
      user = userParam;
    });
  }
}
