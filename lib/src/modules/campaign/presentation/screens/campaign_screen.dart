import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';  // Import the package

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(); // Define controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShadInputFormField(
              controller: textController,
              placeholder: const Text('Search Campaigns'),
              prefix: const Icon(Icons.search), // Replace with your desired icon
              onChanged: (value) {
                // Trigger the search event in the Bloc
                context.read<CampaignBloc>().add(SearchCampaigns(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CampaignBloc, CampaignState>(
              builder: (context, state) {
                // Handle different states
                if (state is CampaignsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CampaignsLoaded) {
                  return ListView.builder(
                    itemCount: state.campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = state.campaigns[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(campaign.description),
                              const SizedBox(height: 8),
                              Text('Rating: ${campaign.rating}'),
                              Text('Price: ${campaign.price}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is CampaignsLoadingError) {
                  return Center(child: Text(state.errorMessage));
                } else {
                  return const Center(child: Text('No campaigns available.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createCampaign);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}