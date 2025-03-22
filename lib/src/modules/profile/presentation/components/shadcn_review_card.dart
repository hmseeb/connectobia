import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/domain/models/review.dart';

class ShadcnReviewCard extends StatelessWidget {
  final Review review;
  final Function(Review)? onDelete;
  final bool canDelete;

  const ShadcnReviewCard({
    super.key,
    required this.review,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get name from expanded record if available
    String reviewerName = _getReviewerName();

    // Format the date
    final formattedDate = DateFormat('MMM d, yyyy').format(review.submittedAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    reviewerName.isNotEmpty
                        ? reviewerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.red.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName.isNotEmpty ? reviewerName : 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Star rating
                _buildRatingStars(),
                if (canDelete && onDelete != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      } else if (value == 'view') {
                        _showFullReview(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View details'),
                          ],
                        ),
                      ),
                      if (canDelete)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Delete review',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReviewContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < review.rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Widget _buildReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stripHtmlTags(review.comment),
          style: const TextStyle(fontSize: 14),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getReviewerName() {
    try {
      // Check who reviewed based on role
      if (review.isBrandReviewer) {
        // Brand gave the review
        if (review.brandRecord != null) {
          return review.brandRecord['brandName'] ?? 'Brand';
        }
        return 'Brand';
      }
      // Influencer gave the review
      else if (review.isInfluencerReviewer) {
        if (review.influencerRecord != null) {
          return review.influencerRecord['fullName'] ?? 'Influencer';
        }
        return 'Influencer';
      }
      return '';
    } catch (e) {
      debugPrint('Error getting reviewer name: $e');
      return '';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
            'Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDelete != null) {
                onDelete!(review);
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFullReview(BuildContext context) {
    String reviewerName = _getReviewerName();
    final formattedDate = DateFormat('MMMM d, yyyy').format(review.submittedAt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Review from ${reviewerName.isNotEmpty ? reviewerName : 'Anonymous'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRatingStars(),
              const SizedBox(height: 8),
              Text('Submitted on $formattedDate'),
              const SizedBox(height: 16),
              Text(
                _stripHtmlTags(review.comment),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              if (review.campaignRecord != null)
                Text(
                    'Campaign: ${review.campaignRecord['title'] ?? 'Unknown campaign'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
          if (canDelete && onDelete != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context);
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  String _stripHtmlTags(String htmlText) {
    // Remove HTML tags
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedText = htmlText.replaceAll(exp, '');

    // Decode common HTML entities
    strippedText = strippedText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    return strippedText;
  }
}

class ShadcnReviewList extends StatelessWidget {
  final List<Review> reviews;
  final String emptyMessage;
  final Function(Review)? onDelete;
  final bool allowDeletion;

  const ShadcnReviewList({
    super.key,
    required this.reviews,
    this.emptyMessage = 'No reviews yet',
    this.onDelete,
    this.allowDeletion = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ShadcnReviewCard(
          review: review,
          onDelete: onDelete,
          canDelete: allowDeletion,
        );
      },
    );
  }
}
