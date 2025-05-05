import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../application/brand_dashboard/brand_dashboard_bloc.dart';

/// Class to represent a filter range with a min and max value
class FilterRange {
  final int min;
  final int max;
  final String label;

  const FilterRange(
      {required this.min, required this.max, required this.label});
}

class InfluencerFilterBottomSheet extends StatefulWidget {
  final String textFilter;
  final Map<String, FilterRange?> selectedRanges;
  final Function(String, Map<String, FilterRange?>) onApplyFilters;

  const InfluencerFilterBottomSheet({
    super.key,
    required this.textFilter,
    required this.selectedRanges,
    required this.onApplyFilters,
  });

  @override
  State<InfluencerFilterBottomSheet> createState() =>
      _InfluencerFilterBottomSheetState();
}

class InfluencerFilterButton extends StatefulWidget {
  const InfluencerFilterButton({super.key});

  @override
  State<InfluencerFilterButton> createState() => InfluencerFilterButtonState();
}

class InfluencerFilterButtonState extends State<InfluencerFilterButton> {
  // Store filter state
  String textFilter = '';
  final Map<String, FilterRange?> selectedRanges = {
    'followers': null,
    'engRate': null,
    'mediaCount': null,
    'avgInteractions': null,
    'avgLikes': null,
    'avgComments': null,
    'avgVideoLikes': null,
    'avgVideoComments': null,
    'avgVideoViews': null,
  };

  // Count of active filters
  int get activeFilterCount =>
      selectedRanges.values.where((range) => range != null).length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: activeFilterCount > 0
              ? BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                )
              : null,
          child: IconButton(
            icon: const Icon(LucideIcons.filter),
            color:
                activeFilterCount > 0 ? Theme.of(context).primaryColor : null,
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ),
        if (activeFilterCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  activeFilterCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Method to clear all filters
  void clearAllFilters() {
    setState(() {
      textFilter = '';
      selectedRanges.forEach((key, _) {
        selectedRanges[key] = null;
      });
    });

    // Reset filters in the bloc
    BlocProvider.of<BrandDashboardBloc>(context).add(
      FilterInfluencers(filter: ''),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InfluencerFilterBottomSheet(
        textFilter: textFilter,
        selectedRanges: Map.from(selectedRanges),
        onApplyFilters: (newTextFilter, newSelectedRanges) {
          setState(() {
            textFilter = newTextFilter;
            selectedRanges.clear();
            selectedRanges.addAll(newSelectedRanges);
          });

          // Create filter data map for the bloc
          final Map<String, RangeValues> filters = {};

          // Add each filter if selected
          selectedRanges.forEach((key, range) {
            if (range != null) {
              filters[key] = RangeValues(
                range.min.toDouble(),
                range.max.toDouble(),
              );
            }
          });

          // Apply filters to the bloc
          BlocProvider.of<BrandDashboardBloc>(context).add(
            AdvancedFilterInfluencers(
              textFilter: textFilter,
              rangeFilters: filters,
            ),
          );
        },
      ),
    );
  }
}

class _InfluencerFilterBottomSheetState
    extends State<InfluencerFilterBottomSheet> {
  // Text filter
  late String textFilter;

  // Selected range for each filter category
  late Map<String, FilterRange?> selectedRanges;

  // Predefined ranges for each filter category
  final List<FilterRange> followerRanges = [
    const FilterRange(min: 1000, max: 50000, label: '1K - 50K'),
    const FilterRange(min: 50000, max: 200000, label: '50K - 200K'),
    const FilterRange(min: 200000, max: 500000, label: '200K - 500K'),
    const FilterRange(min: 500000, max: 1000000, label: '500K - 1M'),
    const FilterRange(min: 1000000, max: 10000000, label: '1M+'),
  ];

  final List<FilterRange> engRateRanges = [
    const FilterRange(min: 1, max: 3, label: '1% - 3%'),
    const FilterRange(min: 3, max: 6, label: '3% - 6%'),
    const FilterRange(min: 6, max: 10, label: '6% - 10%'),
    const FilterRange(min: 10, max: 15, label: '10% - 15%'),
    const FilterRange(min: 15, max: 100, label: '15%+'),
  ];

  final List<FilterRange> mediaCountRanges = [
    const FilterRange(min: 1, max: 50, label: '1 - 50'),
    const FilterRange(min: 50, max: 200, label: '50 - 200'),
    const FilterRange(min: 200, max: 500, label: '200 - 500'),
    const FilterRange(min: 500, max: 1000, label: '500+'),
  ];

  final List<FilterRange> avgInteractionsRanges = [
    const FilterRange(min: 0, max: 1000, label: '< 1K'),
    const FilterRange(min: 1000, max: 5000, label: '1K - 5K'),
    const FilterRange(min: 5000, max: 10000, label: '5K - 10K'),
    const FilterRange(min: 10000, max: 50000, label: '10K - 50K'),
    const FilterRange(min: 50000, max: 1000000, label: '50K+'),
  ];

  final List<FilterRange> avgLikesRanges = [
    const FilterRange(min: 0, max: 1000, label: '< 1K'),
    const FilterRange(min: 1000, max: 5000, label: '1K - 5K'),
    const FilterRange(min: 5000, max: 10000, label: '5K - 10K'),
    const FilterRange(min: 10000, max: 50000, label: '10K - 50K'),
    const FilterRange(min: 50000, max: 1000000, label: '50K+'),
  ];

  final List<FilterRange> avgCommentsRanges = [
    const FilterRange(min: 0, max: 100, label: '< 100'),
    const FilterRange(min: 100, max: 500, label: '100 - 500'),
    const FilterRange(min: 500, max: 1000, label: '500 - 1K'),
    const FilterRange(min: 1000, max: 5000, label: '1K - 5K'),
    const FilterRange(min: 5000, max: 100000, label: '5K+'),
  ];

  final List<FilterRange> avgVideoLikesRanges = [
    const FilterRange(min: 0, max: 1000, label: '< 1K'),
    const FilterRange(min: 1000, max: 5000, label: '1K - 5K'),
    const FilterRange(min: 5000, max: 10000, label: '5K - 10K'),
    const FilterRange(min: 10000, max: 50000, label: '10K - 50K'),
    const FilterRange(min: 50000, max: 1000000, label: '50K+'),
  ];

  final List<FilterRange> avgVideoCommentsRanges = [
    const FilterRange(min: 0, max: 100, label: '< 100'),
    const FilterRange(min: 100, max: 500, label: '100 - 500'),
    const FilterRange(min: 500, max: 1000, label: '500 - 1K'),
    const FilterRange(min: 1000, max: 5000, label: '1K - 5K'),
    const FilterRange(min: 5000, max: 100000, label: '5K+'),
  ];

  final List<FilterRange> avgVideoViewsRanges = [
    const FilterRange(min: 0, max: 5000, label: '< 5K'),
    const FilterRange(min: 5000, max: 20000, label: '5K - 20K'),
    const FilterRange(min: 20000, max: 50000, label: '20K - 50K'),
    const FilterRange(min: 50000, max: 100000, label: '50K - 100K'),
    const FilterRange(min: 100000, max: 10000000, label: '100K+'),
  ];

  // Count active filters
  int get activeFilterCount =>
      selectedRanges.values.where((range) => range != null).length;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Influencers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (activeFilterCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$activeFilterCount active ${activeFilterCount == 1 ? 'filter' : 'filters'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (activeFilterCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              textFilter = '';
                              selectedRanges.forEach((key, _) {
                                selectedRanges[key] = null;
                              });
                            });
                          },
                          child: Text(
                            'Clear All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
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
                      initialValue: textFilter,
                      onChanged: (value) {
                        setState(() {
                          textFilter = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Followers filter
                    _buildSectionTitle('Followers'),
                    _buildFilterChips(
                      ranges: followerRanges,
                      selectedRange: selectedRanges['followers'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['followers'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Engagement Rate filter
                    _buildSectionTitle('Engagement Rate'),
                    _buildFilterChips(
                      ranges: engRateRanges,
                      selectedRange: selectedRanges['engRate'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['engRate'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Media Count filter
                    _buildSectionTitle('Media Count'),
                    _buildFilterChips(
                      ranges: mediaCountRanges,
                      selectedRange: selectedRanges['mediaCount'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['mediaCount'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Interactions filter
                    _buildSectionTitle('Average Interactions'),
                    _buildFilterChips(
                      ranges: avgInteractionsRanges,
                      selectedRange: selectedRanges['avgInteractions'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgInteractions'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Likes filter
                    _buildSectionTitle('Average Likes'),
                    _buildFilterChips(
                      ranges: avgLikesRanges,
                      selectedRange: selectedRanges['avgLikes'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgLikes'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Comments filter
                    _buildSectionTitle('Average Comments'),
                    _buildFilterChips(
                      ranges: avgCommentsRanges,
                      selectedRange: selectedRanges['avgComments'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgComments'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Video Likes filter
                    _buildSectionTitle('Average Video Likes'),
                    _buildFilterChips(
                      ranges: avgVideoLikesRanges,
                      selectedRange: selectedRanges['avgVideoLikes'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgVideoLikes'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Video Comments filter
                    _buildSectionTitle('Average Video Comments'),
                    _buildFilterChips(
                      ranges: avgVideoCommentsRanges,
                      selectedRange: selectedRanges['avgVideoComments'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgVideoComments'] = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Average Video Views filter
                    _buildSectionTitle('Average Video Views'),
                    _buildFilterChips(
                      ranges: avgVideoViewsRanges,
                      selectedRange: selectedRanges['avgVideoViews'],
                      onSelected: (range) {
                        setState(() {
                          selectedRanges['avgVideoViews'] = range;
                        });
                      },
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
                          selectedRanges.forEach((key, _) {
                            selectedRanges[key] = null;
                          });
                        });
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        // Apply filters and go back
                        widget.onApplyFilters(textFilter, selectedRanges);
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

  @override
  void initState() {
    super.initState();
    // Initialize with saved values from parent
    textFilter = widget.textFilter;
    selectedRanges = Map.from(widget.selectedRanges);
  }

  Widget _buildFilterChips({
    required List<FilterRange> ranges,
    required FilterRange? selectedRange,
    required Function(FilterRange?) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "Any" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Any'),
              selected: selectedRange == null,
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedRange == null ? Colors.white : null,
              ),
              onSelected: (bool selected) {
                if (selected) {
                  onSelected(null);
                }
              },
            ),
          ),
          // Range chips
          ...ranges.map((range) {
            final bool isSelected = selectedRange == range;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(range.label),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                ),
                onSelected: (bool selected) {
                  onSelected(selected ? range : null);
                },
              ),
            );
          }),
        ],
      ),
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
