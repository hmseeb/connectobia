import 'package:connectobia/src/modules/profile/data/review_repository.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';

import '../widgets/review_form.dart';

class ReviewScreen extends StatefulWidget {
  final String contractId;

  const ReviewScreen({
    super.key,
    required this.contractId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  Contract? _contract;
  String _errorMessage = '';
  bool _canReview = false;
  bool _isBrand = false;
  String _userId = '';
  String _profileName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Leave a Review', context: context),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadContractAndCheckReviewStatus();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_canReview) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'You have already submitted a review for this contract',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Show the review form
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Rate your experience with $_profileName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ReviewForm(
            onSubmit: _submitReview,
            onCancel: () => Navigator.of(context).pop(),
            isSubmitting: _isSubmitting,
          ),
        ],
      ),
    );
  }

  Future<void> _loadContractAndCheckReviewStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get the current user info
      final pb = await PocketBaseSingleton.instance;
      _userId = pb.authStore.model.id;
      final userCollection = pb.authStore.model.collectionId;
      _isBrand = userCollection == 'brands';

      // Load the contract
      final response = await pb.collection('contracts').getOne(
            widget.contractId,
            expand: 'brand,influencer,campaign',
          );

      final contract = Contract.fromRecord(response);

      // Set default profile name based on the contract
      setState(() {
        _contract = contract;
        // Default profile names (without expanded data)
        _profileName = _isBrand ? 'Influencer' : 'Brand';
      });

      // Try to get better names from the contract's related records if possible
      try {
        if (_isBrand) {
          // Get the influencer name if possible
          final pb = await PocketBaseSingleton.instance;
          final influencer =
              await pb.collection('influencers').getOne(contract.influencer);
          setState(() {
            _profileName = influencer.data['fullName'] ?? 'Influencer';
          });
        } else {
          // Get the brand name if possible
          final pb = await PocketBaseSingleton.instance;
          final brand = await pb.collection('brands').getOne(contract.brand);
          setState(() {
            _profileName = brand.data['brandName'] ?? 'Brand';
          });
        }
      } catch (e) {
        // If we couldn't get the detailed name, keep the default
        debugPrint('Could not fetch detailed profile name: $e');
      }

      // Only allow reviews for completed contracts
      if (contract.status != 'completed') {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'This contract is not yet completed. Reviews can only be submitted for completed contracts.';
          _canReview = false;
        });
        return;
      }

      // Check if the user has already submitted a review
      bool reviewExists;
      if (_isBrand) {
        reviewExists = await ReviewRepository.brandReviewExists(
          campaignId: contract.campaign,
          brandId: _userId,
          influencerId: contract.influencer,
        );
      } else {
        reviewExists = await ReviewRepository.influencerReviewExists(
          campaignId: contract.campaign,
          influencerId: _userId,
          brandId: contract.brand,
        );
      }

      setState(() {
        _isLoading = false;
        _canReview = !reviewExists;
        if (reviewExists) {
          _errorMessage =
              'You have already submitted a review for this contract.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load contract: ${e.toString()}';
        _canReview = false;
      });
    }
  }

  Future<void> _submitReview(int rating, String comment) async {
    if (_contract == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      if (_isBrand) {
        // Brand is reviewing influencer
        await ReviewRepository.createBrandToInfluencerReview(
          campaignId: _contract!.campaign,
          brandId: _userId,
          influencerId: _contract!.influencer,
          rating: rating,
          comment: comment,
        );
      } else {
        // Influencer is reviewing brand
        await ReviewRepository.createInfluencerToBrandReview(
          campaignId: _contract!.campaign,
          influencerId: _userId,
          brandId: _contract!.brand,
          rating: rating,
          comment: comment,
        );
      }

      if (!mounted) return;

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to submit review: ${e.toString()}';
      });
    }
  }
}
