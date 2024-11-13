import 'package:connectobia/globals/constants/avatar.dart';
import 'package:connectobia/globals/constants/industries.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:flutter/material.dart';

class FeatureImageInfo extends StatelessWidget {
  final BrandDashboardLoadedInflueners state;
  final int index;
  const FeatureImageInfo({
    super.key,
    required this.state,
    required this.index,
  });

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
                state.influencers.items[index].avatar.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          Avatar.getUserImage(
                            id: state.influencers.items[index].id,
                            image: state.influencers.items[index].avatar,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                          Avatar.getAvatarPlaceholder(
                            state.influencers.items[index].firstName,
                            state.influencers.items[index].lastName,
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.influencers.items[index].firstName} ${state.influencers.items[index].lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${IndustryFormatter.keyToValue(state.influencers.items[index].industry)} ',
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
