import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/product_tour_overlay.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/application/theme/theme_bloc.dart';
import '../../../../shared/data/constants/avatar.dart';
import '../../../../theme/colors.dart';
import '../../../auth/data/repositories/auth_repo.dart';

class CommonDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String collectionId;
  final String avatar;
  final String userId;
  final String? profileId;

  const CommonDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.collectionId,
    required this.avatar,
    required this.userId,
    this.profileId,
  });

  @override
  Widget build(BuildContext context) {
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
                              // Get the account type
                              final accountType =
                                  CollectionNameSingleton.instance;

                              // If the user has a profile ID, navigate to user profile with self=true
                              if (profileId != null && profileId!.isNotEmpty) {
                                if (accountType == 'influencers') {
                                  // For influencers
                                  Navigator.pushNamed(context, profile,
                                      arguments: {
                                        'profileId': profileId,
                                        'self': true,
                                        'profileType': 'influencers'
                                      });
                                } else {
                                  // For brands
                                  Navigator.pushNamed(context, profile,
                                      arguments: {
                                        'profileId': profileId,
                                        'self': true,
                                        'profileType': 'brands'
                                      });
                                }
                              } else {
                                // Fallback to profile screen if no profile ID
                                Navigator.pushNamed(context, profileScreen);
                              }
                            },
                            child: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(avatar.isNotEmpty
                                      ? Avatar.getUserImage(
                                          collectionId: collectionId,
                                          image: avatar,
                                          recordId: userId,
                                        )
                                      : Avatar.getAvatarPlaceholder(
                                          'HA',
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
                      name,
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
                      email,
                      style: TextStyle(
                        color: state is DarkTheme
                            ? ShadColors.light
                            : ShadColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              // Campaign Help option (only for brands)
              if (collectionId == 'brands')
                ListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.help_outline),
                      SizedBox(width: 16),
                      Text('Campaign Help'),
                    ],
                  ),
                  onTap: () {
                    // Show the product tour again
                    ProductTourOverlay.showAgain();

                    // Close the drawer
                    Navigator.pop(context);

                    // Navigate to the campaigns screen to see the tour
                    Navigator.pushNamed(context, campaignsScreen);
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
                            await AuthRepository.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                welcomeScreen,
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
}
