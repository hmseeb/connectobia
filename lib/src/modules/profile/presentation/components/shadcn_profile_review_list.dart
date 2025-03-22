import 'package:flutter/material.dart';

import '../../../../shared/domain/models/review.dart';
import '../../data/review_repository.dart';
import 'shadcn_review_card.dart';

class ShadcnProfileReviewList extends StatefulWidget {
  final List<Review> reviews;
  final bool isLoading;
  final String userId;
  final String userType; // 'brand' or 'influencer'
  final VoidCallback? onRefresh;
  final double? averageRating;

  const ShadcnProfileReviewList({
    super.key,
    required this.reviews,
    required this.userId,
    required this.userType,
    this.isLoading = false,
    this.onRefresh,
    this.averageRating,
  });

  @override
  State<ShadcnProfileReviewList> createState() =>
      _ShadcnProfileReviewListState();
}

class _ShadcnProfileReviewListState extends State<ShadcnProfileReviewList> {
  String _sortOption = 'newest';
  int? _filterRating;
  bool _isDeleting = false;

  // Determine if user is a brand based on userType - default to false if invalid
  bool get _isBrand {
    if (widget.userType.isEmpty) {
      return false;
    }

    final type = widget.userType.toLowerCase().trim();
    return type == 'brand';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Apply filtering and sorting
    final filteredReviews = _getFilteredReviews();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildFilters(),
        const SizedBox(height: 16),
        if (_isDeleting)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ShadcnReviewList(
            reviews: filteredReviews,
            emptyMessage: 'No reviews yet. Be the first to leave a review!',
            onDelete: _handleDeleteReview,
            allowDeletion: true,
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSortDropdown(),
              TextButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildHeader() {
    final reviewCount = widget.reviews.length;
    final averageRating = widget.averageRating ?? _calculateAverageRating();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reviews ($reviewCount)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (reviewCount > 0)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
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
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
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

  double _calculateAverageRating() {
    if (widget.reviews.isEmpty) return 0.0;

    final sum =
        widget.reviews.fold<int>(0, (sum, review) => sum + review.rating);

    return sum / widget.reviews.length;
  }

  List<Review> _getFilteredReviews() {
    List<Review> filtered = List.from(widget.reviews);

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

  Future<void> _handleDeleteReview(Review review) async {
    // First check if user has permission to delete this review
    final canDelete = await ReviewRepository.canUserDeleteReview(
      userId: widget.userId,
      isBrand: _isBrand,
      review: review,
    );

    if (!canDelete) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have permission to delete this review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await ReviewRepository.deleteReview(review.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh reviews
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
