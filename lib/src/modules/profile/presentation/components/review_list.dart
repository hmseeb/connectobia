import 'package:flutter/material.dart';

import '../../../../shared/domain/models/review.dart';

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final double averageRating;
  final bool isLoading;

  const ReviewList({
    super.key,
    required this.reviews,
    required this.averageRating,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : index < averageRating.ceil() &&
                                    index >= averageRating.floor()
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewTile(review: review);
          },
        ),
      ],
    );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;

  const ReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    String reviewerName = 'Unknown';
    String reviewerAvatar = '';

    // Determine the reviewer based on the role
    if (review.role == 'brand' && review.brandRecord != null) {
      // Brand left review for influencer
      reviewerName = review.brandRecord['brandName'] ?? 'Brand';
      reviewerAvatar = review.brandRecord['avatar'] ?? '';
    } else if (review.role == 'influencer' && review.influencerRecord != null) {
      // Influencer left review for brand
      reviewerName = review.influencerRecord['fullName'] ?? 'Influencer';
      reviewerAvatar = review.influencerRecord['avatar'] ?? '';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: reviewerAvatar.isNotEmpty
                    ? NetworkImage(reviewerAvatar) as ImageProvider
                    : const AssetImage(
                        'assets/illustrations/avatar_placeholder.png'),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(review.submittedAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
