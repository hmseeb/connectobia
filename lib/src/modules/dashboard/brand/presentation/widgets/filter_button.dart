import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../application/brand_dashboard/brand_dashboard_bloc.dart';

class InfluencerFilterBottomSheet extends StatefulWidget {
  const InfluencerFilterBottomSheet({super.key});

  @override
  State<InfluencerFilterBottomSheet> createState() =>
      _InfluencerFilterBottomSheetState();
}

class InfluencerFilterButton extends StatelessWidget {
  const InfluencerFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.filter),
      onPressed: () => _showFilterBottomSheet(context),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const InfluencerFilterBottomSheet(),
    );
  }
}

class _InfluencerFilterBottomSheetState
    extends State<InfluencerFilterBottomSheet> {
  // Filter state variables
  String textFilter = '';
  RangeValues followerRange = const RangeValues(0, 1000000);
  RangeValues engagementRange = const RangeValues(0, 100);
  String? selectedCountry;
  String? selectedGender;

  // Common countries
  final List<String> countries = [
    'All',
    'USA',
    'UK',
    'Canada',
    'Pakistan',
    'India',
    'Australia',
    'Germany',
    'France',
    'Spain',
    'Japan',
  ];

  // Gender options
  final List<String> genders = ['All', 'Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Influencers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Text search
                    _buildSectionTitle('Search by name or industry'),
                    ShadInputFormField(
                      prefix: const Icon(LucideIcons.search, size: 18),
                      placeholder: const Text('Search influencers...'),
                      onChanged: (value) {
                        setState(() {
                          textFilter = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Follower count range
                    _buildSectionTitle('Followers'),
                    _buildRangeSlider(
                      min: 0,
                      max: 1000000,
                      divisions: 20,
                      values: followerRange,
                      labelFormat: (value) => '${value ~/ 1000}K',
                      onChanged: (values) {
                        setState(() {
                          followerRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Engagement rate range
                    _buildSectionTitle('Engagement Rate (%)'),
                    _buildRangeSlider(
                      min: 0,
                      max: 100,
                      divisions: 20,
                      values: engagementRange,
                      labelFormat: (value) => '${value.toInt()}%',
                      onChanged: (values) {
                        setState(() {
                          engagementRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Country filter
                    _buildSectionTitle('Country'),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          final isSelected = selectedCountry == country ||
                              (selectedCountry == null && country == 'All');

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(country),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCountry = selected && country != 'All'
                                      ? country
                                      : null;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gender filter
                    _buildSectionTitle('Gender'),
                    Wrap(
                      spacing: 8,
                      children: genders.map((gender) {
                        final isSelected = selectedGender == gender ||
                            (selectedGender == null && gender == 'All');

                        return FilterChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedGender =
                                  selected && gender != 'All' ? gender : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.secondary(
                      onPressed: () {
                        // Reset all filters
                        setState(() {
                          textFilter = '';
                          followerRange = const RangeValues(0, 1000000);
                          engagementRange = const RangeValues(0, 100);
                          selectedCountry = null;
                          selectedGender = null;
                        });

                        // Apply default filters
                        BlocProvider.of<BrandDashboardBloc>(context).add(
                          FilterInfluencers(filter: ''),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        // Apply filters
                        BlocProvider.of<BrandDashboardBloc>(context).add(
                          AdvancedFilterInfluencers(
                            textFilter: textFilter,
                            followerRange: followerRange,
                            engagementRange: engagementRange,
                            country: selectedCountry,
                            gender: selectedGender,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeSlider({
    required double min,
    required double max,
    required int divisions,
    required RangeValues values,
    required Function(RangeValues) onChanged,
    required String Function(double) labelFormat,
  }) {
    return Column(
      children: [
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(
            labelFormat(values.start),
            labelFormat(values.end),
          ),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(labelFormat(values.start)),
              Text(labelFormat(values.end)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
