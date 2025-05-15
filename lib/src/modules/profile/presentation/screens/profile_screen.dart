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
import '../../../auth/application/auth/auth_bloc.dart';
import '../../../auth/data/repositories/auth_repo.dart';
import '../../../profile/data/review_repository.dart';
import '../../application/user/user_bloc.dart';
import '../widgets/avatar_uploader.dart';
import '../widgets/favorite_floating_button.dart';
import '../widgets/profile_field.dart';
import '../widgets/shadcn_review_card.dart';

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
      appBar: _buildConditionalAppBar(context),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            final user = state.user;
            debugPrint('👂 UserLoaded state received in listener');

            if (user is Brand) {
              debugPrint('👤 Brand user loaded: ${user.brandName}');
            } else if (user is Influencer) {
              debugPrint('👤 Influencer user loaded: ${user.fullName}');
            }

            // If forceRefresh flag is true, immediately refresh data regardless of current state
            if (state.forceRefresh) {
              debugPrint('💫 Force refresh detected in UserLoaded state');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _profileData = null; // Clear cached profile data
                    _isLoadingProfile = true;
                  });

                  if (user is Brand) {
                    final profileId = user.profile;
                    if (profileId.isNotEmpty) {
                      // Use BLoC approach for profile data
                      _refreshProfileData(profileId, true, false);
                    }
                  } else if (user is Influencer) {
                    final profileId = user.profile;
                    if (profileId.isNotEmpty) {
                      _refreshProfileData(profileId, false, false);
                    }
                  }
                }
              });
            }
            // For initial load or when profile data is null
            else if (_profileData == null) {
              // Schedule profile data loading for after the build is complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (user is Brand) {
                    final profileId = user.profile;
                    if (profileId.isNotEmpty) {
                      _refreshProfileData(profileId, true, false);
                    }
                  } else if (user is Influencer) {
                    final profileId = user.profile;
                    if (profileId.isNotEmpty) {
                      _refreshProfileData(profileId, false, false);
                    }
                  }
                }
              });
            }
          } else if (state is UserProfileLoaded) {
            debugPrint('👂 UserProfileLoaded state received in listener');
            final user = state.user;
            if (user is Brand) {
              debugPrint('👤 Profile loaded for brand: ${user.brandName}');
            } else if (user is Influencer) {
              debugPrint('👤 Profile loaded for influencer: ${user.fullName}');
            }

            if (state.profileData != null) {
              if (state.profileData is BrandProfile) {
                debugPrint(
                    '📄 Loaded brand profile data: ${(state.profileData as BrandProfile).description}');
              } else if (state.profileData is InfluencerProfile) {
                debugPrint(
                    '📄 Loaded influencer profile data: ${(state.profileData as InfluencerProfile).description}');
              }
            }

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
            // Always build content with fresh data when forceRefresh is true
            if (state.forceRefresh) {
              return _buildProfileContent(context, state.user);
            }

            // Otherwise respect loading state
            if (_isLoadingProfile) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProfileContent(context, state.user);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(context),
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

    // Use the more robust refresh method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _forceCompleteRefresh();
      }
    });
  }

  /// Conditionally build app bar - only show for own profile
  PreferredSizeWidget? _buildConditionalAppBar(BuildContext context) {
    // Get current auth state to determine if this is the current user's profile
    final authState = context.read<AuthBloc>().state;
    final currentUserState = context.read<UserBloc>().state;

    // Get the current user based on auth state
    dynamic profileUser;
    if (currentUserState is UserLoaded) {
      profileUser = currentUserState.user;
    } else if (currentUserState is UserProfileLoaded) {
      profileUser = currentUserState.user;
    }

    // If it's not our profile, don't show app bar
    if (authState is BrandAuthenticated ||
        authState is InfluencerAuthenticated) {
      final dynamic currentUser = authState is BrandAuthenticated
          ? (authState).user
          : (authState as InfluencerAuthenticated).user;

      if (profileUser != null && currentUser.id != profileUser.id) {
        // Return null for app bar when viewing someone else's profile
        return null;
      }
    }

    // Return regular app bar for own profile
    return transparentAppBar(
      'Profile',
      context: context,
      actions: [
        // Add refresh button to app bar
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Profile',
          onPressed: () {
            debugPrint('🔄 Manual refresh triggered from app bar button');
            _forceCompleteRefresh();
          },
        ),
      ],
    );
  }

  /// Build chat and favorite buttons for viewing other profiles
  Widget? _buildFloatingActionButtons(BuildContext context) {
    // Get current auth state to determine if this is the current user's profile
    final authState = context.read<AuthBloc>().state;
    final currentUserState = context.read<UserBloc>().state;

    // Get the current profile user
    dynamic profileUser;
    if (currentUserState is UserLoaded) {
      profileUser = currentUserState.user;
    } else if (currentUserState is UserProfileLoaded) {
      profileUser = currentUserState.user;
    } else {
      // If we can't determine the profile user, don't show FABs
      return null;
    }

    // Get current authenticated user
    dynamic currentUser;
    if (authState is BrandAuthenticated) {
      currentUser = authState.user;
    } else if (authState is InfluencerAuthenticated) {
      currentUser = authState.user;
    } else {
      // If not authenticated, don't show FABs
      return null;
    }

    // If viewing someone else's profile
    if (profileUser != null &&
        currentUser != null &&
        currentUser.id != profileUser.id) {
      // Determine if we should show chat button
      bool showChatButton = false;

      // For influencers, only show if they have connected social accounts
      if (profileUser is Influencer) {
        showChatButton = profileUser.connectedSocial;
      } else if (profileUser is Brand) {
        // Always show chat for brands regardless of Instagram connection
        showChatButton = true;
      }

      // Return row of floating action buttons
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Chat button - if applicable
            if (showChatButton)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FloatingActionButton(
                  heroTag: 'chat-button',
                  onPressed: () => _openChatScreen(context, profileUser),
                  backgroundColor: Colors.blue,
                  elevation: 6.0,
                  tooltip: "Start chat",
                  child: const Icon(Icons.chat, color: Colors.white, size: 28),
                ),
              ),

            // Favorite button
            FavoriteFloatingButton(
              targetUser: profileUser,
              currentUser: currentUser,
            ),
          ],
        ),
      );
    }

    // Default edit button for own profile
    return FloatingActionButton(
      onPressed: () async {
        final currentContext = context;
        final currentState = currentContext.read<UserBloc>().state;
        final currentUser = (currentState is UserLoaded)
            ? (currentState).user
            : (currentState is UserProfileLoaded)
                ? (currentState).user
                : null;

        if (currentUser != null) {
          // Show loading indicator before navigation
          setState(() {
            _isLoadingProfile = true;
          });

          try {
            if (!mounted) return;

            // Instead of replacing the screen, let's force a complete data refresh from the backend
            // Clear state and show loading indicator
            setState(() {
              _profileData = null;
              _isLoadingProfile = true;
            });

            // Force refresh by loading fresh data from the backend first
            final freshUser = await AuthRepository.getUser();
            if (freshUser != null) {
              // Update bloc with fresh user data
              context.read<UserBloc>().add(UpdateUserState(freshUser));

              // Get the profile ID based on user type
              final String profileId;
              final bool isBrand;

              if (freshUser is Brand) {
                profileId = freshUser.profile;
                isBrand = true;
              } else if (freshUser is Influencer) {
                profileId = freshUser.profile;
                isBrand = false;
              } else {
                profileId = '';
                isBrand = false;
              }

              // Refresh profile data if we have a valid profile ID
              if (profileId.isNotEmpty) {
                await _refreshProfileData(profileId, isBrand, true);
              }
            }
          } catch (e) {
            debugPrint('Error navigating to edit profile: $e');
            if (mounted) {
              setState(() {
                _isLoadingProfile = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error opening profile editor: $e')),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cannot edit profile: User data not available')),
          );
        }
      },
      backgroundColor: Colors.red.shade400,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic user) {
    // Clear profile data if the new user doesn't match current profile data's user
    if (_profileData != null) {
      final String profileId = user is Brand ? user.profile : user.profile;
      if (_profileData is BrandProfile &&
          (_profileData as BrandProfile).id != profileId) {
        _profileData = null;
      } else if (_profileData is InfluencerProfile &&
          (_profileData as InfluencerProfile).id != profileId) {
        _profileData = null;
      }
    }

    // Extract user details
    final userId = user.id;
    String name = '';
    String username = '';
    String email = '';
    String industry = '';
    String avatar = '';
    bool isBrand = false;
    String profileId = '';
    bool hasConnectedInstagram = false;

    // Determine if user is a brand and extract appropriate data
    if (user is Brand) {
      isBrand = true;
      name = user.brandName;
      debugPrint('📋 Building profile content with brand name: $name');
      email = user.email;
      industry = user.industry;
      avatar = user.avatar;
      profileId = user.profile;
      // Brands don't have Instagram connection
      hasConnectedInstagram =
          true; // Always true for brands to hide the connection card

      // Load profile data if needed
      if (_profileData == null && profileId.isNotEmpty) {
        debugPrint('🔍 Need to load brand profile data for ID: $profileId');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Always use BLoC approach - direct loading is failing
            _refreshProfileData(profileId, true, false);
          }
        });
      }
    } else if (user is Influencer) {
      name = user.fullName;
      debugPrint('📋 Building profile content with influencer name: $name');
      username = user.username;
      email = user.email;
      industry = user.industry;
      avatar = user.avatar;
      profileId = user.profile;
      hasConnectedInstagram = user.connectedSocial;

      // Load profile data if needed
      if (_profileData == null && profileId.isNotEmpty) {
        debugPrint(
            '🔍 Need to load influencer profile data for ID: $profileId');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Always use BLoC approach - direct loading is failing
            _refreshProfileData(profileId, false, false);
          }
        });
      }
    }

    // Build the profile content
    return RefreshIndicator(
      onRefresh: () async {
        // Enhanced refresh functionality
        debugPrint('🔄 Manual refresh triggered by pull-to-refresh');

        // Clear profile data
        setState(() {
          _profileData = null;
          _isLoadingProfile = true;
        });

        try {
          // Get fresh user data directly from repository
          final user = await AuthRepository.getUser();
          if (user != null) {
            debugPrint('✅ Fresh user data fetched on manual refresh');

            if (mounted) {
              // Update the bloc with fresh data
              context.read<UserBloc>().add(UpdateUserState(user));

              // Directly load profile data with direct approach
              if (user is Brand && user.profile.isNotEmpty) {
                await _refreshProfileData(user.profile, true, true);
                debugPrint('✅ Successfully refreshed brand profile data');
              } else if (user is Influencer && user.profile.isNotEmpty) {
                await _refreshProfileData(user.profile, false, true);
                debugPrint('✅ Successfully refreshed influencer profile data');
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to refresh user data')),
              );
            }
          }
        } catch (e) {
          debugPrint('❌ Error during manual refresh: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error refreshing: $e')),
            );
          }
        } finally {
          // Ensure loading indicator is hidden if something went wrong
          if (mounted && _isLoadingProfile) {
            setState(() {
              _isLoadingProfile = false;
            });
          }
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add loading indicator at the top when refreshing
              if (_isLoadingProfile)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ShadCard(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Refreshing profile...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  // Force a complete refresh from the backend
  Future<void> _forceCompleteRefresh() async {
    try {
      // Clear all cached data
      setState(() {
        _profileData = null;
        _isLoadingProfile = true;
      });

      debugPrint('🔄 Forcing complete profile refresh from backend');

      // Get fresh user data directly from repository
      final user = await AuthRepository.getUser();
      if (user != null) {
        debugPrint('✅ Fresh user data fetched directly from repository');

        // Log user details for debugging
        if (user is Brand) {
          debugPrint(
              '👤 Refreshed brand data - Name: ${user.brandName}, Industry: ${user.industry}');

          // Directly load the profile data with the direct loading approach
          if (user.profile.isNotEmpty) {
            _refreshProfileData(user.profile, true, true);
          }
        } else if (user is Influencer) {
          debugPrint(
              '👤 Refreshed influencer data - Name: ${user.fullName}, Industry: ${user.industry}');

          // Directly load the profile data with the direct loading approach
          if (user.profile.isNotEmpty) {
            _refreshProfileData(user.profile, false, true);
          }
        }

        // Update the bloc with fresh data
        if (mounted) {
          context.read<UserBloc>().add(UpdateUserState(user));
        }
      } else {
        // Fallback to using bloc's FetchUser
        debugPrint('⚠️ Direct user fetch returned null, falling back to bloc');
        if (mounted) {
          context.read<UserBloc>().add(FetchUser());
        }
      }
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
      // Fallback to using bloc's FetchUser
      if (mounted) {
        context.read<UserBloc>().add(FetchUser());
      }
    }
  }

  // Open chat screen with the user being viewed
  void _openChatScreen(BuildContext context, dynamic targetUser) {
    Navigator.pushNamed(
      context,
      messagesScreen,
      arguments: {
        'userId': targetUser.id,
        'name':
            targetUser is Brand ? targetUser.brandName : targetUser.fullName,
        'avatar': targetUser.avatar,
        'collectionId': targetUser.collectionId,
        'hasConnectedInstagram':
            targetUser is Influencer ? targetUser.connectedSocial : false,
        'chatExists': false, // Create new chat if it doesn't exist
      },
    );
  }

  Future<void> _refreshProfileData(
      String profileId, bool isBrand, bool useDirectLoading) async {
    if (_isLoadingProfile || profileId.isEmpty) return;

    final BuildContext currentContext = context;

    debugPrint(
        '🔍 Refreshing profile data: profileId=$profileId, isBrand=$isBrand, useDirectLoading=$useDirectLoading');

    setState(() {
      _profileData = null; // Explicitly clear profile data
      _isLoadingProfile = true;
    });

    try {
      // Use direct loading approach to bypass any caching
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          isBrand ? 'brandProfile' : 'influencerProfile';

      debugPrint(
          '📥 Attempting to load ${isBrand ? "brand" : "influencer"} profile directly with ID: $profileId');

      // Add a cache-busting parameter to force a fresh fetch from the database
      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      // Force database refresh by clearing any cached data
      await pb.collection(profileCollectionName).authRefresh();

      debugPrint(
          '✅ Successfully found profile record with ID: ${profileRecord.id}');

      if (!mounted) return;

      // Create the appropriate profile object
      dynamic profileData;
      if (isBrand) {
        profileData = BrandProfile.fromRecord(profileRecord);
      } else {
        profileData = InfluencerProfile.fromRecord(profileRecord);
      }

      // Use BLoC to update the state
      final userState = currentContext.read<UserBloc>().state;
      if (userState is UserLoaded) {
        // Update the BLoC with profile data
        currentContext.read<UserBloc>().add(
              UpdateUserState(userState.user),
            );

        setState(() {
          _profileData = profileData;
          _isLoadingProfile = false;
        });
      } else {
        // If we don't have a valid user state, try to get fresh user data
        final freshUser = await AuthRepository.getUser();
        if (freshUser != null && mounted) {
          // Update the BLoC with fresh user and profile data
          context.read<UserBloc>().add(UpdateUserState(freshUser));

          setState(() {
            _profileData = profileData;
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading profile data directly: $e');

      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile data: $e')),
        );
      }
    }
  }
}
