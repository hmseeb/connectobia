import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../src/modules/profile/data/review_repository.dart';
import '../../../../../src/shared/domain/models/review.dart';
import '../../../profile/presentation/widgets/shadcn_review_card.dart';

class ProfileReviews extends StatefulWidget {
  final String profileId;
  final bool isBrand;
  final String? averageRating;

  const ProfileReviews({
    super.key,
    required this.profileId,
    required this.isBrand,
    this.averageRating,
  });

  @override
  State<ProfileReviews> createState() => _ProfileReviewsState();
}

class _ProfileReviewsState extends State<ProfileReviews> {
  bool _isLoading = true;
  List<Review> _reviews = [];
  String _error = '';
  double _averageRating = 0.0;
  int? _filterRating;
  String _sortOption = 'newest';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewsHeader(),
              const SizedBox(height: 8),
              const Divider(thickness: 1.5, height: 1.5),
              const SizedBox(height: 16),
              if (_reviews.isEmpty)
                _buildEmptyReviewsState()
              else ...[
                _buildSummaryMetrics(),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                _buildReviewsList(),
                if (_getFilteredReviews().length > 3)
                  _buildSeeAllReviewsButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProfileReviews oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId) {
      _loadReviews();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Widget _buildCompactRatingDistribution() {
    // Count reviews by rating
    Map<int, int> ratingCounts = {};
    for (var review in _reviews) {
      ratingCounts[review.rating] = (ratingCounts[review.rating] ?? 0) + 1;
    }

    // Calculate percentages
    Map<int, double> ratingPercentages = {};
    for (int i = 5; i >= 1; i--) {
      ratingPercentages[i] = (_reviews.isEmpty)
          ? 0
          : ((ratingCounts[i] ?? 0) / _reviews.length) * 100;
    }

    return Column(
      children: List.generate(5, (index) {
        int rating = 5 - index;
        double percentage = ratingPercentages[rating] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Text(
                '$rating',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 12, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyReviewsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Reviews will appear here when someone rates this profile',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.red.shade100, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading reviews',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ShadButton(
              onPressed: _loadReviews,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 18),
                  const SizedBox(width: 8),
                  const Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filter & Sort',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            _buildSortDropdown(),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRatingFilterChip(null, 'All'),
              const SizedBox(width: 8),
              _buildRatingFilterChip(5, '5'),
              const SizedBox(width: 8),
              _buildRatingFilterChip(4, '4'),
              const SizedBox(width: 8),
              _buildRatingFilterChip(3, '3'),
              const SizedBox(width: 8),
              _buildRatingFilterChip(2, '2'),
              const SizedBox(width: 8),
              _buildRatingFilterChip(1, '1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading reviews...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    // Count reviews by rating
    Map<int, int> ratingCounts = {};
    for (var review in _reviews) {
      ratingCounts[review.rating] = (ratingCounts[review.rating] ?? 0) + 1;
    }

    // Calculate percentages
    Map<int, double> ratingPercentages = {};
    for (int i = 5; i >= 1; i--) {
      ratingPercentages[i] = (_reviews.isEmpty)
          ? 0
          : ((ratingCounts[i] ?? 0) / _reviews.length) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          int rating = 5 - index;
          double percentage = ratingPercentages[rating] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  child: Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage / 100,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 35,
                  child: Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRatingFilterChip(int? rating, String label) {
    final isSelected = _filterRating == rating;

    return FilterChip(
      label: Row(
        children: [
          Text(label),
          if (rating != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 16, color: Colors.amber),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterRating = selected ? rating : null;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildReviewsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title and rating tag
        Row(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_averageRating >= 4.5 && _reviews.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Excellent (${_reviews.length})',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        // Rating pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                widget.averageRating != null
                    ? widget.averageRating!
                    : _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    final filteredReviews = _getFilteredReviews();
    final displayCount =
        filteredReviews.length > 3 ? 3 : filteredReviews.length;

    if (filteredReviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.filter_alt_off,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No reviews match your filters',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: () {
                  setState(() {
                    _filterRating = null;
                    _sortOption = 'newest';
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return ShadcnReviewCard(
          review: filteredReviews[index],
          canDelete: false,
        );
      },
    );
  }

  Widget _buildSeeAllReviewsButton() {
    final filteredReviews = _getFilteredReviews();

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Center(
        child: ShadButton(
          onPressed: () => _showAllReviewsDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_outlined, size: 18),
              const SizedBox(width: 8),
              Text('See all ${filteredReviews.length} reviews'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortOption,
      underline: Container(height: 0),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: const [
        DropdownMenuItem(value: 'newest', child: Text('Newest')),
        DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
        DropdownMenuItem(value: 'highest', child: Text('Highest rated')),
        DropdownMenuItem(value: 'lowest', child: Text('Lowest rated')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortOption = value;
          });
        }
      },
    );
  }

  Widget _buildSummaryMetrics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating display
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.averageRating != null
                        ? widget.averageRating!
                        : _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "${_reviews.length} ${_reviews.length == 1 ? 'review' : 'reviews'}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // Star rating row
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    bool isFilled = index < _averageRating.floor();
                    bool isHalfFilled = index == _averageRating.floor() &&
                        _averageRating - _averageRating.floor() >= 0.5;

                    return Icon(
                      isFilled
                          ? Icons.star
                          : (isHalfFilled
                              ? Icons.star_half
                              : Icons.star_border),
                      color: Colors.amber.shade600,
                      size: 18,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        // Rating distribution bar chart
        Expanded(
          flex: 2,
          child: _buildCompactRatingDistribution(),
        ),
      ],
    );
  }

  List<Review> _getFilteredReviews() {
    List<Review> filtered = List.from(_reviews);

    // Apply rating filter
    if (_filterRating != null) {
      filtered =
          filtered.where((review) => review.rating == _filterRating).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'newest':
        filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
        break;
      case 'highest':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filtered.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    return filtered;
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _reviews = [];
    });

    try {
      // Load reviews depending on whether this is a brand or influencer profile
      if (widget.isBrand) {
        _reviews = await ReviewRepository.getReviewsForBrand(widget.profileId);
        _averageRating =
            await ReviewRepository.getBrandAverageRating(widget.profileId);
      } else {
        _reviews =
            await ReviewRepository.getReviewsForInfluencer(widget.profileId);
        _averageRating =
            await ReviewRepository.getInfluencerAverageRating(widget.profileId);
      }

      // Sort reviews by date (newest first)
      _reviews.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _showAllReviewsDialog(BuildContext context) {
    final filteredReviews = _getFilteredReviews();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 550, // Set a max width for better readability
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_rate_rounded,
                          size: 28,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Reviews',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${_getRatingText(_averageRating)} (${filteredReviews.length})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (filteredReviews.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildRatingDistribution(),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter & Sort',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              StatefulBuilder(
                                  builder: (context, setDialogState) {
                                return DropdownButton<String>(
                                  value: _sortOption,
                                  underline: Container(height: 0),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'newest', child: Text('Newest')),
                                    DropdownMenuItem(
                                        value: 'oldest', child: Text('Oldest')),
                                    DropdownMenuItem(
                                        value: 'highest',
                                        child: Text('Highest rated')),
                                    DropdownMenuItem(
                                        value: 'lowest',
                                        child: Text('Lowest rated')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _sortOption = value;
                                      });
                                      setDialogState(() {});
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StatefulBuilder(builder: (context, setDialogState) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('All'),
                                    selected: _filterRating == null,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _filterRating = null;
                                        });
                                        setDialogState(() {});
                                      }
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    selectedColor:
                                        Colors.green.withOpacity(0.2),
                                    checkmarkColor: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(5, (index) {
                                    final rating = 5 - index;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: FilterChip(
                                        label: Row(
                                          children: [
                                            Text('$rating'),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.star,
                                                size: 16, color: Colors.amber),
                                          ],
                                        ),
                                        selected: _filterRating == rating,
                                        onSelected: (selected) {
                                          setState(() {
                                            _filterRating =
                                                selected ? rating : null;
                                          });
                                          setDialogState(() {});
                                        },
                                        backgroundColor: Colors.grey.shade200,
                                        selectedColor:
                                            Colors.green.withOpacity(0.2),
                                        checkmarkColor: Colors.green,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filteredReviews.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt_off,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No reviews match your filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ShadButton.outline(
                                onPressed: () {
                                  setState(() {
                                    _filterRating = null;
                                    _sortOption = 'newest';
                                  });
                                  // Force dialog to rebuild with new filters
                                  Navigator.of(context).pop();
                                  _showAllReviewsDialog(context);
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          return ShadcnReviewCard(
                            review: filteredReviews[index],
                            canDelete: false,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
