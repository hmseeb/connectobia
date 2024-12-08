import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:flutter/material.dart';

class FeatureImageInfo extends StatefulWidget {
  final BrandDashboardLoadedInflueners state;
  final Influencer user;
  const FeatureImageInfo({
    super.key,
    required this.state,
    required this.user,
  });

  @override
  State<FeatureImageInfo> createState() => _FeatureImageInfoState();
}

class _FeatureImageInfoState extends State<FeatureImageInfo> {
  int page = BrandDashboardBloc().page;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Semi-transparent background
            borderRadius: BorderRadius.circular(36),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    Avatar.getAvatarPlaceholder(
                      widget.user.fullName,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: widget.user.connectedSocial
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ],
                    ),
                    Text(
                      '@${widget.user.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
