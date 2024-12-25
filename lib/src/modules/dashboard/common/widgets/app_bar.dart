import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/application/theme/theme_bloc.dart';
import '../../../../shared/data/constants/avatar.dart';
import '../../../../shared/data/constants/greetings.dart';
import '../../../../theme/colors.dart';

class CommonAppBar extends StatelessWidget {
  final String userName;
  final String searchPlaceholder;
  final String userId;
  final String collectionId;
  final String image;
  const CommonAppBar(
      {super.key,
      required this.userName,
      required this.searchPlaceholder,
      required this.userId,
      required this.collectionId,
      required this.image});

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
              child: ShadInputFormField(
                placeholder: Text(searchPlaceholder),
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
