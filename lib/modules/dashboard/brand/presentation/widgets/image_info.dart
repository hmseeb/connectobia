import 'package:flutter/material.dart';

import '../../../../../common/constants/avatar.dart';
import '../../application/brand_dashboard/brand_dashboard_bloc.dart';

class FeatureImageInfo extends StatefulWidget {
  final String title;
  final String subTitle;
  final bool connectedSocial;
  final String avatar;
  final String userId;
  final String collectionId;

  const FeatureImageInfo({
    super.key,
    required this.title,
    required this.subTitle,
    required this.connectedSocial,
    required this.avatar,
    required this.userId,
    required this.collectionId,
  });

  @override
  State<FeatureImageInfo> createState() => _FeatureImageInfoState();
}

class _FeatureImageInfoState extends State<FeatureImageInfo> {
  int page = BrandDashboardBloc().page;
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    bool hasAvatar = widget.avatar.isNotEmpty;
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: brightness == Brightness.dark
                ? Colors.black.withOpacity(0.70)
                : Colors.white.withOpacity(0.70), // Semi-transparent background
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
                    hasAvatar
                        ? Avatar.getUserImage(
                            userId: widget.userId,
                            image: widget.avatar,
                            collectionId: widget.collectionId,
                          )
                        : Avatar.getAvatarPlaceholder(
                            widget.title,
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
                          widget.title,
                          style: TextStyle(
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: widget.connectedSocial
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ],
                    ),
                    Text(
                      widget.subTitle,
                      style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
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
