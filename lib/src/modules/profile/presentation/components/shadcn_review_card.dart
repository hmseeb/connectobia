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

    // Get reviewer avatar if available
    String? avatarUrl;
    try {
      if (review.isBrandReviewer && review.brandRecord != null) {
        avatarUrl = review.brandRecord['avatar'];
      } else if (review.isInfluencerReviewer &&
          review.influencerRecord != null) {
        avatarUrl = review.influencerRecord['avatar'];
      }
    } catch (e) {
      debugPrint('Error getting reviewer avatar: $e');
    }

    // Generate a gradient background based on rating
    final gradientColors = _getGradientColorsForRating(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rating indicator at top
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),

          // Main content
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with nice shadow and border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(avatarUrl),
                                backgroundColor: Colors.grey.shade200,
                              )
                            : CircleAvatar(
                                radius: 26,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Text(
                                  reviewerName.isNotEmpty
                                      ? reviewerName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and options row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    reviewerName.isNotEmpty
                                        ? reviewerName
                                        : 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (canDelete && onDelete != null)
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          _showOptionsBottomSheet(context);
                                        },
                                        child: const Icon(
                                          Icons.more_horiz,
                                          size: 20,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Stars and date on same row
                            Row(
                              children: [
                                // Rating stars
                                _buildAnimatedRatingStars(context),

                                // Date with subtle style
                                Text(
                                  " · $formattedDate",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quotation mark for review
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.format_quote,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  // Review content
                  _buildReviewContent(context),

                  // Campaign info if available
                  if (review.campaignRecord != null) ...[
                    const SizedBox(height: 16),
                    _buildCampaignInfo(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRatingStars(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        bool filled = index < review.rating;

        return Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? Colors.amber.shade600 : Colors.grey.shade300,
            size: 16,
          ),
        );
      }),
    );
  }

  Widget _buildCampaignInfo(BuildContext context) {
    final campaignTitle = review.campaignRecord['title'] ?? 'Unknown campaign';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              campaignTitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context) {
    final reviewText = _stripHtmlTags(review.comment);

    return GestureDetector(
      onTap: () {
        if (reviewText.length > 150) {
          _showFullReview(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reviewText,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade800,
              letterSpacing: -0.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (reviewText.length > 150) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getGradientColorsForRating(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final primaryLight = HSLColor.fromColor(primaryColor)
        .withLightness(HSLColor.fromColor(primaryColor).lightness + 0.1)
        .toColor();

    switch (review.rating) {
      case 5:
        return [primaryColor, primaryLight];
      case 4:
        return [primaryColor.withOpacity(0.9), primaryLight.withOpacity(0.9)];
      case 3:
        return [Colors.amber.shade600, Colors.amber.shade400];
      case 2:
        return [Colors.orange.shade600, Colors.orange.shade400];
      case 1:
        return [Colors.red.shade600, Colors.red.shade400];
      default:
        return [Colors.grey.shade600, Colors.grey.shade400];
    }
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
              _buildAnimatedRatingStars(context),
              const SizedBox(height: 8),
              Text('Submitted on $formattedDate'),
              const SizedBox(height: 16),
              _buildReviewContent(context),
              const SizedBox(height: 24),
              if (review.campaignRecord != null) _buildCampaignInfo(context),
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

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View full review'),
                onTap: () {
                  Navigator.pop(context);
                  _showFullReview(context);
                },
              ),
              if (canDelete)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete review',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),
            ],
          ),
        ),
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
