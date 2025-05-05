import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/dashboard/common/data/repositories/dashboard_repo.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/extensions/string_extention.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SelectInfluencerStep extends StatefulWidget {
  final Function(List<String>) onSelectedInfluencersChanged;
  final String? initialSelectedInfluencer;

  const SelectInfluencerStep({
    super.key,
    required this.onSelectedInfluencersChanged,
    this.initialSelectedInfluencer,
  });

  @override
  State<SelectInfluencerStep> createState() => _SelectInfluencerStepState();
}

class _SelectInfluencerStepState extends State<SelectInfluencerStep>
    with SingleTickerProviderStateMixin {
  final List<String> _selectedInfluencers = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool _isLoading = true;
  List<Influencer> _influencers = [];
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Influencer> get filteredInfluencers {
    return _influencers.where((influencer) {
      // Apply search filter
      final matchesSearch = searchQuery.isEmpty ||
          influencer.fullName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          influencer.username.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Select Influencer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search Bar with Card
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Influencers',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                ShadInputFormField(
                  controller: searchController,
                  placeholder:
                      const Text('Search influencers by name or username...'),
                  prefix: const Icon(Icons.search, color: AppColors.primary),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  suffix: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Available Influencers Header and List
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Available Influencers',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    if (!_isLoading && _errorMessage == null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredInfluencers.length} found',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (!_isLoading && filteredInfluencers.isNotEmpty)
                      IconButton(
                        icon:
                            const Icon(Icons.refresh, color: AppColors.primary),
                        tooltip: 'Refresh',
                        onPressed: _loadInfluencers,
                      ),
                  ],
                ),
                Container(
                  height: 250,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : _errorMessage != null
                          ? _buildErrorState()
                          : filteredInfluencers.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: filteredInfluencers.length,
                                  shrinkWrap: false,
                                  itemBuilder: (context, index) {
                                    final influencer =
                                        filteredInfluencers[index];
                                    final isSelected = _selectedInfluencers
                                        .contains(influencer.id);

                                    return _buildInfluencerCard(
                                        influencer, isSelected);
                                  },
                                ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Selected Influencer Card
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text(
                      'Selected Influencer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  height: 83,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedInfluencers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1,
                                  color:
                                      AppColors.textSecondary.withOpacity(0.5),
                                  size: 28),
                              const SizedBox(height: 4),
                              Text(
                                'No influencer selected',
                                style: TextStyle(
                                  color:
                                      AppColors.textSecondary.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _selectedInfluencers.length,
                          itemBuilder: (context, index) {
                            final influencerId = _selectedInfluencers[index];
                            final influencer = _influencers.firstWhere(
                              (inf) => inf.id == influencerId,
                              orElse: () => Influencer(
                                collectionId: '',
                                collectionName: '',
                                id: '',
                                email: '',
                                avatar: '',
                                banner: '',
                                emailVisibility: false,
                                verified: false,
                                fullName: 'Unknown',
                                username: 'unknown',
                                connectedSocial: false,
                                onboarded: false,
                                industry: '',
                                profile: '',
                                created: DateTime.now(),
                                updated: DateTime.now(),
                              ),
                            );
void _toggleInfluencerSelection(String influencerId) {
  setState(() {
    if (_selectedInfluencers.contains(influencerId)) {
      _selectedInfluencers.clear();
    } else {
      _selectedInfluencers.clear();
      _selectedInfluencers.add(influencerId);
    }
    widget.onSelectedInfluencersChanged(_selectedInfluencers);
  });
}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.person, size: size * 0.6, color: Colors.grey)
          : null,
    );
  }
}

                            return ListTile(
                              leading: Hero(
                                tag: 'influencer-${influencer.id}',
                                child: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  backgroundImage: CachedNetworkImageProvider(
                                    Avatar.getUserImage(
                                      collectionId: influencer.collectionId,
                                      image: '',
                                      recordId: influencer.id,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                influencer.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '@${influencer.username} | ${influencer.industry} | build.users',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: AppColors.error),
                                onPressed: () =>
                                    _toggleInfluencerSelection(influencerId),
                              ),
                            );
                          },
                        ),
                ),Container(
  height: 250,
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: _isLoading
      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
      : _errorMessage != null
          ? _buildErrorState()
          : filteredInfluencers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filteredInfluencers.length,
                  itemBuilder: (context, index) {
                    final influencer = filteredInfluencers[index];
                    final isSelected = _selectedInfluencers.contains(influencer.id);
                    return _buildInfluencerCard(influencer, isSelected);
                  },
                ),
)

              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize with the influencer if provided
    if (widget.initialSelectedInfluencer != null &&
        widget.initialSelectedInfluencer!.isNotEmpty) {
      _selectedInfluencers.add(widget.initialSelectedInfluencer!);
    }

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Load influencers data
    _loadInfluencers();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching influencers found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load influencers',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loadInfluencers,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfluencerCard(Influencer influencer, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleInfluencerSelection(influencer.id),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Influencer Avatar
                CachedNetworkImage(
                  imageUrl: influencer.avatar.isNotEmpty
                      ? influencer.avatar
                      : Avatar.getUserImage(
                          collectionId: influencer.collectionId,
                          image: '',
                          recordId: influencer.id,
                        ),
                  placeholder: (context, url) => const CircleAvatar(
                    radius: 25,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 25,
                    backgroundImage: imageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                // Influencer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              influencer.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Username and Follower Count
                      Row(
                        children: [
                          Text(
                            '@${influencer.username}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '100k+ followers',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Industry
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          influencer.industry.capitalize(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadInfluencers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final influencers = await DashboardRepository.getInfluencersList();
      setState(() {
        _influencers = influencers.items;
        _isLoading = false;

        // Check if influencers list is empty and set a friendly message
        if (_influencers.isEmpty) {
          _errorMessage =
              'No verified influencers available yet. Make sure there are verified influencer profiles in the system.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load influencers: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleInfluencerSelection(String influencerId) {
    setState(() {
      // If the selected influencer is already selected, deselect it
      if (_selectedInfluencers.contains(influencerId)) {
        _selectedInfluencers.clear();
      } else {
        // Deselect any previously selected influencer and select the new one
        _selectedInfluencers.clear();
        _selectedInfluencers.add(influencerId);
      }
      widget.onSelectedInfluencersChanged(_selectedInfluencers);
    });
  }
}
