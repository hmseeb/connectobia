import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/dashboard/brand/presentation/widgets/filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/application/theme/theme_bloc.dart';
import '../../../../shared/data/constants/avatar.dart';
import '../../../../shared/data/constants/greetings.dart';
import '../../../../theme/colors.dart';

class CommonAppBar extends StatefulWidget {
  final Function(String) onChange;
  final String userName;
  final String searchPlaceholder;
  final String userId;
  final String collectionId;
  final String image;
  final bool showFilterButton;
  final Widget? walletWidget;
  final GlobalKey<InfluencerFilterButtonState>? filterButtonKey;

  const CommonAppBar({
    super.key,
    required this.userName,
    required this.searchPlaceholder,
    required this.userId,
    required this.collectionId,
    required this.image,
    required this.onChange,
    this.showFilterButton = false,
    this.walletWidget,
    this.filterButtonKey,
  });

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  // Reference to the filter button if not provided externally
  late final GlobalKey<InfluencerFilterButtonState> _filterButtonKey =
      widget.filterButtonKey ?? GlobalKey<InfluencerFilterButtonState>();

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
          title: Text(Greetings.getGreeting(widget.userName)),
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(widget.walletWidget != null ? 120 : 69),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Search field
                      Expanded(
                        child: ShadInputFormField(
                          prefix: const Icon(LucideIcons.search),
                          placeholder: Text(widget.searchPlaceholder),
                          onChanged: widget.onChange,
                        ),
                      ),

                      // Filter button if enabled
                      if (widget.showFilterButton) ...[
                        const SizedBox(width: 8),
                        InfluencerFilterButton(key: _filterButtonKey),
                      ],
                    ],
                  ),

                  // Wallet widget if provided (now below search)
                  if (widget.walletWidget != null) ...[
                    const SizedBox(height: 8),
                    widget.walletWidget!,
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
                  widget.image.isNotEmpty
                      ? Avatar.getUserImage(
                          recordId: widget.userId,
                          image: widget.image,
                          collectionId: widget.collectionId,
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

  // Method to clear all filters
  void clearAllFilters() {
    if (widget.showFilterButton && _filterButtonKey.currentState != null) {
      _filterButtonKey.currentState!.clearAllFilters();
    }
  }
}
