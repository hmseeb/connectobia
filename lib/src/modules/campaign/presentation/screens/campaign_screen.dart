import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_card.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/search_field.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar(
        'Campaigns',
        context: context,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CampaignBloc>().add(LoadCampaigns());
            },
          ),
        ],
      ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignsLoadingError) {
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<CampaignBloc>().add(LoadCampaigns());
  }

  Widget _buildCampaignsList(CampaignState state) {
    if (state is CampaignsLoaded) {
      if (state.campaigns.isEmpty) {
        return const Center(
          child:
              Text('No campaigns found. Create one by tapping the + button.'),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<CampaignBloc>().add(LoadCampaigns());
        },
        child: ListView.builder(
          itemCount: state.campaigns.length,
          itemBuilder: (context, index) {
            final campaign = state.campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CampaignCard(
                campaign: campaign,
                onDeleted: () {
                  context.read<CampaignBloc>().add(LoadCampaigns());
                },
              ),
            );
          },
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
      return const Center(
        child: Text('Press the refresh button to load campaigns'),
      );
    }
  }
}
