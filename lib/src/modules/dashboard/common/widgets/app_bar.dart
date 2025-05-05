import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/dashboard/brand/presentation/widgets/filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/application/theme/theme_bloc.dart';
import '../../../../shared/data/constants/avatar.dart';
import '../../../../shared/data/constants/greetings.dart';
import '../../../../theme/colors.dart';

class CommonAppBar extends StatelessWidget {
  final Function(String) onChange;
  final String userName;
  final String searchPlaceholder;
  final String userId;
  final String collectionId;
  final String image;
  final bool showFilterButton;

  const CommonAppBar({
    super.key,
    required this.userName,
    required this.searchPlaceholder,
    required this.userId,
    required this.collectionId,
    required this.image,
    required this.onChange,
    this.showFilterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return SliverAppBar(
          elevation: 0,
          backgroundColor:
              state is DarkTheme ? ShadColors.dark : ShadColors.light,
          floating: true,
          pinned: true,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: Text(Greetings.getGreeting(userName)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(69),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: ShadInputFormField(
                      prefix: const Icon(LucideIcons.search),
                      placeholder: Text(searchPlaceholder),
                      onChanged: onChange,
                    ),
                  ),

                  // Filter button if enabled
                  if (showFilterButton) ...[
                    const SizedBox(width: 8),
                    const InfluencerFilterButton(),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
                // or navigate to profile
                // Navigator.pushNamed(context, profileScreen);
              },
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  image.isNotEmpty
                      ? Avatar.getUserImage(
                          recordId: userId,
                          image: image,
                          collectionId: collectionId,
                        )
                      : Avatar.getAvatarPlaceholder('HA'),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}
