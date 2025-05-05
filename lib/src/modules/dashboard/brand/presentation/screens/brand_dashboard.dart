import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/brand_featured_listing.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_screen.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/chatting/presentation/screens/chats_screen.dart';
import 'package:connectobia/src/modules/dashboard/brand/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/src/modules/dashboard/brand/presentation/widgets/filter_button.dart';
import 'package:connectobia/src/modules/dashboard/common/widgets/app_bar.dart';
import 'package:connectobia/src/modules/notifications/application/notification_bloc.dart';
import 'package:connectobia/src/modules/notifications/presentation/screens/notifications_screen.dart';
import 'package:connectobia/src/modules/wallet/application/wallet/wallet_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/funds.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  late ScrollController scrollController;
  int _selectedIndex = 0;
  // Use a regular key since we'll do null checks before using
  final GlobalKey appBarKey = GlobalKey();
  // Create a filter button key to access it directly
  final GlobalKey<InfluencerFilterButtonState> filterButtonKey =
      GlobalKey<InfluencerFilterButtonState>();
  bool _hasActiveFilters = false;
  late WalletBloc _walletBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletBloc>(
      create: (context) => _walletBloc,
      child: BlocListener<RealtimeMessagingBloc, RealtimeMessagingState>(
        listener: (context, state) {
          if (state is MessageNotificationReceived) {
            DelightToastBar(
              snackbarDuration: const Duration(seconds: 5),
              position: DelightSnackbarPosition.top,
              builder: (context) => ToastCard(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    Avatar.getUserImage(
                      recordId: state.userId,
                      image: state.avatar,
                      collectionId: state.collectionId,
                    ),
                  ),
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
              ),
            ).show(context);
          }
        },
        child: Scaffold(
          endDrawer: CommonDrawer(
            name: widget.user.brandName,
            email: widget.user.email,
            collectionId: widget.user.collectionId,
            avatar: widget.user.avatar,
            userId: widget.user.id,
            profileId: widget.user.profile,
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  CommonAppBar(
                    key: appBarKey,
                    userName: widget.user.brandName,
                    searchPlaceholder: 'Search for influencers',
                    userId: widget.user.id,
                    collectionId: widget.user.collectionId,
                    image: widget.user.avatar,
                    showFilterButton: true,
                    filterButtonKey: filterButtonKey,
                    walletWidget: BlocBuilder<WalletBloc, WalletState>(
                      buildWhen: (previous, current) {
                        // Rebuild whenever the state is loaded
                        return current is WalletLoaded;
                      },
                      builder: (context, state) {
                        if (state is WalletLoaded) {
                          return _buildWalletCard(state.funds);
                        }
                        return _buildWalletCard(null);
                      },
                    ),
                    onChange: (value) {
                      BlocProvider.of<BrandDashboardBloc>(context)
                          .add(FilterInfluencers(filter: value));
                    },
                  ),
                ],
                body: BlocConsumer<BrandDashboardBloc, BrandDashboardState>(
                  listener: (context, state) {
                    if (state is BrandDashboardLoadedInfluencers) {
                      // Check if filters are active by comparing to the total count
                      _setActiveFilters(
                          BlocProvider.of<BrandDashboardBloc>(context)
                                      .influencers !=
                                  null &&
                              state.influencers.totalItems !=
                                  BlocProvider.of<BrandDashboardBloc>(context)
                                      .influencers!
                                      .totalItems);
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: SectionTitle('Featured Influencers'),
                                ),
                                if (_hasActiveFilters)
                                  TextButton.icon(
                                    onPressed: () {
                                      // Clear filters directly in the bloc
                                      BlocProvider.of<BrandDashboardBloc>(
                                              context)
                                          .add(
                                        FilterInfluencers(filter: ''),
                                      );

                                      // Reset the filter button state directly
                                      if (filterButtonKey.currentState !=
                                          null) {
                                        filterButtonKey.currentState!
                                            .clearAllFilters();
                                      }

                                      setState(() {
                                        _hasActiveFilters = false;
                                      });
                                    },
                                    icon: const Icon(Icons.filter_alt_off,
                                        size: 16),
                                    label: const Text('Clear Filters'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const BrandFeaturedListings(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const CampaignScreen(),
              const Chats(),
              const NotificationsScreen(),
            ],
          ),
          bottomNavigationBar: buildBottomNavigationBar(
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    BlocProvider.of<BrandDashboardBloc>(context)
        .add(BrandDashboardLoadInfluencers());

    // Initialize wallet bloc
    _walletBloc = WalletBloc()..add(WalletLoadFunds(widget.user.id));

    // Subscribe to real-time messages
    context.read<RealtimeMessagingBloc>().add(SubscribeMessages());

    // Fetch notifications
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  Widget _buildWalletCard(Funds? funds) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: ShadCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  funds != null
                      ? 'PKR ${funds.balance.toStringAsFixed(2)}'
                      : 'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  walletScreen,
                  arguments: {
                    'userId': widget.user.id,
                  },
                );

                // Refresh wallet balance when coming back from wallet screen
                if (result != null) {
                  _walletBloc.add(WalletLoadFunds(widget.user.id));
                } else {
                  // Also refresh if no result to ensure latest balance
                  _walletBloc.add(WalletLoadFunds(widget.user.id));
                }
              },
              child: const Text('Top up'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    // Reset the bloc filters directly
    BlocProvider.of<BrandDashboardBloc>(context).add(
      FilterInfluencers(filter: ''),
    );

    // Reset the filter button state directly
    if (filterButtonKey.currentState != null) {
      filterButtonKey.currentState!.clearAllFilters();
    }

    setState(() {
      _hasActiveFilters = false;
    });
  }

  void _setActiveFilters(bool hasFilters) {
    setState(() {
      _hasActiveFilters = hasFilters;
    });
  }
}
