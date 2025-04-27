import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_card.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_error_boundary.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/search_field.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/swipe_hint.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampaignScreen extends StatefulWidget {
  static final RouteObserver<ModalRoute<dynamic>> routeObserver =
      RouteObserver<ModalRoute<dynamic>>();

  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen>
    with WidgetsBindingObserver, RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _screenFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _screenFocusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          debugPrint('CampaignScreen got focus, loading campaigns');
          context.read<CampaignBloc>().add(LoadCampaigns());
        }
      },
      child: Scaffold(
        appBar: transparentAppBar(
          'Campaigns',
          context: context,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                debugPrint('Refresh button pressed, loading campaigns');
                context.read<CampaignBloc>().add(LoadCampaigns());
              },
            ),
          ],
        ),
        body: BlocConsumer<CampaignBloc, CampaignState>(
          listener: (context, state) {
            if (state is CampaignsLoadingError) {
              debugPrint('Campaign loading error: ${state.errorMessage}');
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: Text(state.errorMessage),
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchField(
                    controller: _searchController,
                    onSearch: (query) {
                      context.read<CampaignBloc>().add(SearchCampaigns(query));
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildCampaignsList(state),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(createCampaign);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, loading campaigns');
      context.read<CampaignBloc>().add(LoadCampaigns());
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      debugPrint('Subscribing CampaignScreen to route observer');
      CampaignScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    debugPrint('CampaignScreen didPopNext called (returned to this screen)');
    context.read<CampaignBloc>().add(LoadCampaigns());
    super.didPopNext();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _screenFocusNode.dispose();
    CampaignScreen.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('CampaignScreen initializing, loading campaigns');
    // Immediate request to load campaigns
    context.read<CampaignBloc>().add(LoadCampaigns());

    // Add post-frame callback to request focus after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Post-frame callback, requesting focus');
      _screenFocusNode.requestFocus();
      // Additional safety measure to load campaigns after render
      context.read<CampaignBloc>().add(LoadCampaigns());
    });
  }

  Widget _buildCampaignsList(CampaignState state) {
    debugPrint('Building campaigns list with state: ${state.runtimeType}');
    if (state is CampaignsLoaded) {
      if (state.campaigns.isEmpty) {
        return const Center(
          child:
              Text('No campaigns found. Create one by tapping the + button.'),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          debugPrint('Pull-to-refresh triggered, loading campaigns');
          context.read<CampaignBloc>().add(LoadCampaigns());
        },
        child: CampaignErrorBoundary(
          child: Column(
            children: [
              // Show swipe hint at the top
              const SwipeHint(),
              // Campaigns list
              Expanded(
                child: ListView.builder(
                  itemCount: state.campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = state.campaigns[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CampaignErrorBoundary(
                        child: CampaignCard(
                          campaign: campaign,
                          onDeleted: () {
                            context.read<CampaignBloc>().add(LoadCampaigns());
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is CampaignsLoading) {
      // Show skeleton loading UI
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CampaignCard(
                campaign: null,
                onDeleted: () {},
              ),
            );
          },
        ),
      );
    } else {
      // Initial state or any other state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No campaigns loaded'),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: () {
                debugPrint('Load campaigns button pressed');
                context.read<CampaignBloc>().add(LoadCampaigns());
              },
              child: const Text('Load Campaigns'),
            ),
          ],
        ),
      );
    }
  }
}
