import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_screen.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/presentation/screens/chats_screen.dart';
import 'package:connectobia/src/shared/application/realtime/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../shared/data/constants/industries.dart';
import '../../../../../shared/domain/models/influencer.dart';
import '../../../common/widgets/app_bar.dart';
import '../../../common/widgets/bottom_navigation.dart';
import '../../../common/widgets/drawer.dart';
import '../../../common/widgets/section_title.dart';
import '../widgets/influencer_featured_listings.dart';

class InfluencerDashboard extends StatefulWidget {
  final Influencer user;
  const InfluencerDashboard({super.key, required this.user});

  @override
  State<InfluencerDashboard> createState() => _InfluencerDashboardState();
}

class _InfluencerDashboardState extends State<InfluencerDashboard> {
  late Influencer user = widget.user;
  late final brightness = ShadTheme.of(context).brightness;
  final ScrollController scrollController = ScrollController();

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeMessagingBloc, RealtimeMessagingState>(
      listener: (context, state) {
        if (state is RealtimeMessageReceived) {
          DelightToastBar(
              autoDismiss: true,
              position: DelightSnackbarPosition.top,
              builder: (context) => ToastCard(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          Avatar.getUserImage(
                              userId: state.userId,
                              image: state.avatar,
                              collectionId: state.collectionId)),
                    ),
                    onTap: () {
                      BlocProvider.of<RealtimeMessagingBloc>(context)
                          .add(GetMessagesByUserId(state.userId));
                      Navigator.pushNamed(
                        context,
                        singleChatScreen,
                        arguments: {
                          'userId': state.userId,
                          'name': state.name,
                          'avatar': state.avatar,
                          'collectionId': state.collectionId,
                          'hasConnectedInstagram': state.hasConnectedInstagram,
                        },
                      );
                    },
                    title: Text(
                      state.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      state.message.messageText.length > 30
                          ? '${state.message.messageText.substring(0, 30)}...'
                          : state.message.messageText,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  )).show(context);
        }
      },
      child: Scaffold(
        endDrawer: CommonDrawer(
          name: user.fullName,
          email: user.email,
          collectionId: user.collectionId,
          avatar: '',
          userId: user.id,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            NestedScrollView(
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
                      const SectionTitle('Featured Brands'),
                      const SizedBox(height: 16),
                      InfluencerFeaturedListings(),
                    ],
                  ),
                ),
              ),
            ),
            CampaignScreen(),
            Chats(),
            Placeholder(),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            // Get chats when the chats screen is selected
            if (index == 2) {
              BlocProvider.of<ChatsBloc>(context).add(GetChats());

              // Unsubscribe from chats when the chats screen is not selected
            } else if (index != 2 && _selectedIndex == 2) {
              BlocProvider.of<ChatsBloc>(context).add(UnsubscribeChats());
            }

            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
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
    scrollController.addListener(_scrollListener); // Pass the function directly
  }

  _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {}
  }
}
