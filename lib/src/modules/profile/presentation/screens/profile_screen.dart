import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/screens.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../shared/domain/models/review.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../../profile/data/review_repository.dart';
import '../../application/user/user_bloc.dart';
import '../components/avatar_uploader.dart';
import '../components/profile_field.dart';
import '../components/shadcn_review_card.dart';

class ProfileReviewsWidget extends StatefulWidget {
  final String userId;
  final bool isBrand;

  const ProfileReviewsWidget({
    super.key,
    required this.userId,
    required this.isBrand,
  });

  @override
  State<ProfileReviewsWidget> createState() => _ProfileReviewsWidgetState();
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileReviewsWidgetState extends State<ProfileReviewsWidget> {
  bool _isLoading = true;
  List<Review> _reviews = [];
  String _error = '';
  double _averageRating = 0.0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
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
                'Error loading reviews: $_error',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadReviews,
                tooltip: "Refresh reviews",
              ),
            ],
          ),
        ),
        if (_reviews.isEmpty)
          Card(
            margin: const EdgeInsets.all(16),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No reviews yet. Your received reviews will appear here.',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
        else
          ShadcnReviewList(
            reviews: _reviews,
            emptyMessage: 'No reviews yet.',
            onDelete: null, // Don't allow deletion from this view
            allowDeletion: false,
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant ProfileReviewsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.isBrand != widget.isBrand) {
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
        _reviews = await ReviewRepository.getReviewsForBrand(widget.userId);
        _averageRating =
            await ReviewRepository.getBrandAverageRating(widget.userId);
      } else {
        _reviews =
            await ReviewRepository.getReviewsForInfluencer(widget.userId);
        _averageRating =
            await ReviewRepository.getInfluencerAverageRating(widget.userId);
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
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _profileData;
  bool _isLoadingProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Profile', context: context),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded && _profileData == null) {
            // Schedule profile data loading for after the build is complete
            final user = state.user;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (user is Brand) {
                  final profileId = user.profile;
                  if (profileId.isNotEmpty) {
                    _refreshProfileData(profileId, true);
                  }
                } else if (user is Influencer) {
                  final profileId = user.profile;
                  if (profileId.isNotEmpty) {
                    _refreshProfileData(profileId, false);
                  }
                }
              }
            });

            setState(() {
              _isLoadingProfile = false;
            });
          } else if (state is UserProfileLoaded) {
            setState(() {
              _profileData = state.profileData;
              _isLoadingProfile = false;
            });
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else if (state is UserProfileLoaded) {
            return _buildProfileContent(context, state.user);
          } else if (state is UserLoaded) {
            if (_isLoadingProfile) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProfileContent(context, state.user);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final currentContext = context;
          await Navigator.pushNamed(context, editProfileScreen);
          // Refresh data when returning from edit screen
          if (!mounted) return;
          setState(() {
            _profileData = null; // Clear cached profile data
            _isLoadingProfile = false;
          });
          currentContext.read<UserBloc>().add(FetchUser()); // Refresh user data
        },
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  @override
  void dispose() {
    _profileData = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _profileData = null;
    context.read<UserBloc>().add(FetchUser());
  }

  Widget _buildProfileContent(BuildContext context, dynamic user) {
    // Extract user details
    final userId = user.id;
    String name = '';
    String username = '';
    String email = '';
    String industry = '';
    String avatar = '';
    bool isBrand = false;
    String profileId = '';

    // Determine if user is a brand and extract appropriate data
    if (user is Brand) {
      isBrand = true;
      name = user.brandName;
      email = user.email;
      industry = user.industry;
      avatar = user.avatar;
      profileId = user.profile;

      // Schedule profile data loading for after the build is complete
      if (_profileData == null && profileId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshProfileData(profileId, true);
          }
        });
      }
    } else if (user is Influencer) {
      name = user.fullName;
      username = user.username;
      email = user.email;
      industry = user.industry;
      avatar = user.avatar;
      profileId = user.profile;

      // Schedule profile data loading for after the build is complete
      if (_profileData == null && profileId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshProfileData(profileId, false);
          }
        });
      }
    }

    // Build the profile content
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the user data
        if (mounted) {
          context.read<UserBloc>().add(FetchUser());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and name section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AvatarUploader(
                    avatarUrl: avatar,
                    userId: userId,
                    collectionId: user.collectionId,
                    isEditable: false,
                    size: 80,
                    onAvatarSelected: (file) {
                      // Not editable in profile view
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isBrand ? 'Brand' : 'Influencer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Wallet button for brands
              if (isBrand) ...[
                _buildWalletButton(context, userId),
                const SizedBox(height: 24),
              ],
              // Profile fields
              ProfileField(
                label: 'Email',
                value: email,
                icon: Icons.email,
                isEditable: false,
              ),
              const SizedBox(height: 16),

              if (!isBrand) ...[
                ProfileField(
                  label: 'Username',
                  value: username,
                  icon: Icons.alternate_email,
                  isEditable: false,
                ),
                const SizedBox(height: 16),
              ],

              ProfileField(
                label: 'Industry',
                value: industry,
                icon: Icons.category,
                isEditable: false,
              ),
              const SizedBox(height: 24),

              // Bio field
              Builder(builder: (context) {
                // Show loading indicator if profile data is being loaded
                if (_isLoadingProfile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      const SizedBox(height: 8),
                      ShadCard(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Loading bio...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                String bioText = '';

                // Get description directly from the profile data
                if (_profileData != null) {
                  if (_profileData is BrandProfile) {
                    bioText = (_profileData as BrandProfile).description;
                    debugPrint('📄 Using bio from BrandProfile: $bioText');
                  } else if (_profileData is InfluencerProfile) {
                    bioText = (_profileData as InfluencerProfile).description;
                    debugPrint('📄 Using bio from InfluencerProfile: $bioText');
                  }

                  // Clean HTML tags if present
                  bioText = _cleanHtmlTags(bioText);
                  debugPrint('🧹 Cleaned bio text: "$bioText"');
                } else {
                  debugPrint('⚠️ _profileData is null, no bio will be shown');
                }

                return ProfileBioField(
                  label: 'About',
                  value: bioText,
                  isEditable: false,
                );
              }),

              const SizedBox(height: 24),

              // Reviews Section
              const Divider(),

              // Use our custom ProfileReviewsWidget that loads reviews
              ProfileReviewsWidget(
                userId: userId,
                isBrand: isBrand,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build wallet button for brands
  Widget _buildWalletButton(BuildContext context, String userId) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.red.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your funds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Add funds in PKR to create campaigns',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                walletScreen,
                arguments: {
                  'userId': userId,
                },
              );
            },
            child: const Text('View Wallet'),
          ),
        ],
      ),
    );
  }

  // Helper method to clean HTML tags from text
  String _cleanHtmlTags(String text) {
    if (text.isEmpty) return text;

    // Remove HTML paragraphs
    String cleaned = text;
    if (cleaned.contains('<p>') || cleaned.contains('</p>')) {
      cleaned = cleaned.replaceAll('<p>', '').replaceAll('</p>', '');
    }

    // Remove other common HTML tags
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    cleaned = cleaned.replaceAll(exp, '');

    // Decode common HTML entities
    cleaned = cleaned
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    // Trim any whitespace
    cleaned = cleaned.trim();

    return cleaned;
  }

  Future<void> _refreshProfileData(String profileId, bool isBrand) async {
    if (_isLoadingProfile || profileId.isEmpty) return;

    final BuildContext currentContext = context;

    debugPrint(
        '🔍 Refreshing profile data: profileId=$profileId, isBrand=$isBrand');

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          isBrand ? 'brandProfile' : 'influencerProfile';

      debugPrint('📥 Fetching from collection: $profileCollectionName');

      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      debugPrint('✅ Profile record fetched: ${profileRecord.id}');
      debugPrint('📋 Profile data: ${profileRecord.data}');

      if (!mounted) return;

      setState(() {
        if (isBrand) {
          _profileData = BrandProfile.fromRecord(profileRecord);
          debugPrint(
              '📝 Brand bio: ${(_profileData as BrandProfile).description}');
        } else {
          _profileData = InfluencerProfile.fromRecord(profileRecord);
          debugPrint(
              '📝 Influencer bio: ${(_profileData as InfluencerProfile).description}');
        }
        _isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
