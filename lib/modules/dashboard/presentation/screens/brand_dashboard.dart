import 'package:colorful_safe_area/colorful_safe_area.dart';
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
    return ColorfulSafeArea(
      color: brightness == Brightness.dark
          ? ShadColors.kForeground
          : ShadColors.kBackground,
      child: Scaffold(
        endDrawer: profileDrawer(context),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              automaticallyImplyLeading: false,
              snap: true,
              floating: true,
              pinned: true,
              scrolledUnderElevation: 0,
              backgroundColor: brightness == Brightness.dark
                  ? ShadColors.kForeground
                  : ShadColors.kBackground,
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
                    // _navigateAndDisplaySelection(context);
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: ShadAvatar(
                    UserAvatar.getAvatarUrl(user.firstName, user.lastName),
                    placeholder:
                        Text('${user.firstName[0]} ${user.lastName[0]}'),
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
          brightness: brightness,
        ),
      ),
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

  BlocConsumer<ThemeBloc, ThemeState> profileDrawer(BuildContext context) {
    return BlocConsumer<ThemeBloc, ThemeState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: brightness == Brightness.dark
                      ? ShadColors.kForeground
                      : ShadColors.kBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShadAvatar(
                          UserAvatar.getAvatarUrl(
                              user.firstName, user.lastName),
                          placeholder:
                              Text('${user.firstName[0]} ${user.lastName[0]}'),
                        ),

                        // toggle theme button
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            brightness == Brightness.dark
                                ? LucideIcons.sun
                                : LucideIcons.moon,
                            color: brightness == Brightness.dark
                                ? ShadColors.kBackground
                                : ShadColors.kForeground,
                          ),
                          onPressed: () {
                            bool isDarkMode = brightness == Brightness.dark;
                            isDarkMode = !isDarkMode;
                            // TODO: Fix theme breaks when toggling
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
                        color: brightness == Brightness.dark
                            ? ShadColors.kBackground
                            : ShadColors.kForeground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: brightness == Brightness.dark
                            ? ShadColors.kBackground
                            : ShadColors.kForeground,
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
                  final theme = ShadTheme.of(context);
                  await AuthRepo.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome',
                      (route) => false,
                      arguments: {
                        'isDarkMode': theme.brightness == Brightness.dark
                      },
                    );
                  }
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
