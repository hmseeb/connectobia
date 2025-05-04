import 'package:flutter/material.dart';

import '../../../../../src/modules/profile/data/review_repository.dart';
import '../../../../../src/modules/profile/presentation/components/shadcn_review_card.dart';
import '../../../../../src/shared/domain/models/review.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading reviews',
                style: TextStyle(color: Colors.red[700]),
              ),
              TextButton(
                onPressed: _loadReviews,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews (${_reviews.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_reviews.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),
            if (_reviews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length > 3 ? 3 : _reviews.length,
                itemBuilder: (context, index) {
                  return ShadcnReviewCard(
                    review: _reviews[index],
                    canDelete: false,
                  );
                },
              ),
            if (_reviews.length > 3)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {
                    _showAllReviewsDialog(context);
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text(
                    'See all ${_reviews.length} reviews',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          ],
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All Reviews (${_reviews.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return ShadcnReviewCard(
                      review: _reviews[index],
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
