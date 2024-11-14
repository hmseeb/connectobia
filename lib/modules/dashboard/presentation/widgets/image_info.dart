import 'package:connectobia/globals/constants/avatar.dart';
import 'package:connectobia/globals/constants/industries.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/domain/user_list.dart';
import 'package:flutter/material.dart';

class FeatureImageInfo extends StatefulWidget {
  final BrandDashboardLoadedInflueners state;
  final Item user;
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
                widget.user.avatar.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          Avatar.getUserImage(
                            id: widget.user.id,
                            image: widget.user.avatar,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                          Avatar.getAvatarPlaceholder(
                            widget.user.firstName,
                            widget.user.lastName,
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.user.firstName} ${widget.user.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${IndustryFormatter.keyToValue(widget.user.industry)} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '\$100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
