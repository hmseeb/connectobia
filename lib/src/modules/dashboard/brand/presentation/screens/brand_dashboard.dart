import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/brand_featured_listing.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_screen.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/chatting/presentation/screens/chats_screen.dart';
import 'package:connectobia/src/modules/dashboard/brand/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/src/modules/notifications/application/notification_bloc.dart';
import 'package:connectobia/src/modules/notifications/presentation/screens/notifications_screen.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/widgets/app_bar.dart';
import '../../../common/widgets/bottom_navigation.dart';
import '../../../common/widgets/drawer.dart';
import '../../../common/widgets/section_title.dart';

class BrandDashboard extends StatefulWidget {
  final Brand user;
  const BrandDashboard({super.key, required this.user});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  final scrollController = ScrollController();
  late Brand user = widget.user;
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeMessagingBloc, RealtimeMessagingState>(
      listener: (context, state) {
        if (state is MessageNotificationReceived) {
          DelightToastBar(
              autoDismiss: true,
              position: DelightSnackbarPosition.top,
              builder: (context) => ToastCard(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          Avatar.getUserImage(
                              recordId: state.userId,
                              image: state.avatar,
                              collectionId: state.collectionId)),
                    ),
                    onTap: () {
                      BlocProvider.of<RealtimeMessagingBloc>(context)
                          .add(GetMessagesByUserId(state.userId));
                      Navigator.pushNamed(
                        context,
                        messagesScreen,
                        arguments: {
                          'userId': state.userId,
                          'name': state.name,
                          'avatar': state.avatar,
                          'collectionId': state.collectionId,
                          'hasConnectedInstagram': state.hasConnectedInstagram,
                          'chatExists': true,
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
                      state.message,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  )).show(context);
        }
      },
      child: Scaffold(
        endDrawer: CommonDrawer(
          name: user.brandName,
          email: user.email,
          collectionId: user.collectionId,
          avatar: user.avatar,
          userId: user.id,
          profileId: user.profile,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                CommonAppBar(
                  userName: user.brandName,
                  searchPlaceholder: 'Search for influencers',
                  userId: user.id,
                  collectionId: user.collectionId,
                  image: user.avatar,
                  showFilterButton: true,
                  onChange: (value) {
                    BlocProvider.of<BrandDashboardBloc>(context)
                        .add(FilterInfluencers(filter: value));
                  },
                ),
              ],
              body: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWalletCard(),
                      const SectionTitle('Featured Influencers'),
                      const SizedBox(height: 16),
                      const BrandFeaturedListings(),
                    ],
                  ),
                ),
              ),
            ),
            const CampaignScreen(),
            const Chats(),
            const NotificationsScreen(),
          ],
        ),
        bottomNavigationBar: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            return buildBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 2) {
                  BlocProvider.of<ChatsBloc>(context).add(GetChats());
                }
                if (index == 3) {
                  // Refresh notifications when the tab is selected
                  BlocProvider.of<NotificationBloc>(context)
                      .add(FetchNotifications());
                }
              },
            );
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

  @override
  void initState() {
    super.initState();
    user = widget.user;
    scrollController.addListener(_scrollListener); // Pass the function directly

    // Subscribe to real-time messages
    context.read<RealtimeMessagingBloc>().add(SubscribeMessages());

    // Fetch notifications
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  Widget _buildWalletCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade400.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage your funds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add funds in PKR to create campaigns',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            ShadButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  walletScreen,
                  arguments: {
                    'userId': user.id,
                  },
                );
              },
              child: const Text('View Wallet'),
            ),
          ],
        ),
      ),
    );
  }

  _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {}
  }
}
