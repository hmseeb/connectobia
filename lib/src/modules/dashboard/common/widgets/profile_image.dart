// Reusable widget for profile image
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/shared/application/theme/theme_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileImage extends StatelessWidget {
  final String userId;
  final String avatar;
  final String banner;
  final String collectionId;
  final Function() onBackButtonPressed;
  final String? name; // Add optional name parameter

  const ProfileImage({
    super.key,
    required this.userId,
    required this.avatar,
    required this.banner,
    required this.collectionId,
    required this.onBackButtonPressed,
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
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ShadColors.primary,
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
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ShadColors.primary,
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

          // Back button
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Positioned(
                top: 40,
                left: 10,
                child: Center(
                  child: IconButton(
                    onPressed: onBackButtonPressed,
                    icon: Icon(
                      Icons.arrow_back,
                      color: ShadColors.disabled,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
