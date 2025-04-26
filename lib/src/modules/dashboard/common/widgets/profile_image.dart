// Reusable widget for profile image
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/shared/application/theme/theme_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileImage extends StatelessWidget {
  final String userId;
  final String avatar;
  final String banner;
  final String collectionId;
  final Function() onBackButtonPressed;
  final Function()? onRefreshPressed; // Add refresh button callback
  final String? name; // Add optional name parameter

  const ProfileImage({
    super.key,
    required this.userId,
    required this.avatar,
    required this.banner,
    required this.collectionId,
    required this.onBackButtonPressed,
    this.onRefreshPressed,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    // Extract initials from name or use default
    final String initials = name != null && name!.isNotEmpty
        ? name!.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner image with error handling
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: banner.isNotEmpty
                  ? Avatar.getUserImage(
                      recordId: userId,
                      image: banner,
                      collectionId: collectionId,
                    )
                  : Avatar.getBannerPlaceholder(),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Skeletonizer(
                  enabled: true,
                  containersColor: Colors.grey[300],
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.white,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.image, color: Colors.grey[400], size: 40),
                ),
              ),
            ),
          ),

          // Avatar with error handling
          Positioned(
            bottom: 0,
            left: 10,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: ShadColors.primary.withOpacity(0.1),
                  child: avatar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: Avatar.getUserImage(
                            recordId: userId,
                            image: avatar,
                            collectionId: collectionId,
                          ),
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 48,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            child: Skeletonizer(
                              enabled: true,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ShadColors.primary,
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ShadColors.primary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Back and refresh buttons
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 40,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: IconButton(
                        onPressed: onBackButtonPressed,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Refresh button (only if callback provided)
                  if (onRefreshPressed != null)
                    Positioned(
                      top: 40,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: IconButton(
                          onPressed: onRefreshPressed,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
