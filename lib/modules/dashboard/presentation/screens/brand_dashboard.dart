import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/constants/greetings.dart';
import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/constants/screen_size.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/views/edit_influencer_profile.dart';
import 'package:connectobia/modules/dashboard/presentation/views/featured_listing.dart';
import 'package:connectobia/modules/dashboard/presentation/views/popular_categories.dart';
import 'package:connectobia/modules/dashboard/presentation/views/user_setting.dart';
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
  final ScrollController scrollController = ScrollController();

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
                elevation: 0,
                backgroundColor:
                    state is DarkTheme ? ShadColors.dark : ShadColors.light,
                floating: true,
                pinned: true,
                scrolledUnderElevation: 0,
                centerTitle: false,
                title: Text(Greetings.getGreeting(user.firstName)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(69),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ShadInputFormField(
                      placeholder:
                          const Text('Search for services or influencers'),
                      prefix: const Icon(LucideIcons.search),
                      suffix: const Icon(LucideIcons.filter),
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
                        user.avatar.isNotEmpty
                            ? Avatar.getUserImage(
                                id: user.id,
                                image: user.avatar,
                              )
                            : Avatar.getAvatarPlaceholder(
                                user.firstName, user.lastName),
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
                  controller: scrollController,
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

  BlocBuilder<ThemeBloc, ThemeState> profileDrawer(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShadTooltip(
                          builder: (context) => const Text('Edit Profile'),
                          child: GestureDetector(
                            onTap: () {
                              _displayEditUserSettings(context);
                            },
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  user.avatar.isNotEmpty
                                      ? Avatar.getUserImage(
                                          id: user.id,
                                          image: user.avatar,
                                        )
                                      : Avatar.getAvatarPlaceholder(
                                          user.firstName,
                                          user.lastName,
                                        )),
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
                    Icon(LucideIcons.settings),
                    SizedBox(width: 16),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  _displayEditInfluencerProfile(context);
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
                                '/welcomeScreen',
                                (route) => false,
                              );
                            }
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
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final userParam = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSettingSheet(
          user: user,
        ),
      ),
    );
    if (userParam == null) return;
    setState(() {
      user = userParam;
    });
  }

  _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // TODO: Load more influencers
    }
  }
}
