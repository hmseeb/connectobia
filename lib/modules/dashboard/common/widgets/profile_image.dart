// Reusable widget for profile image
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String userId;
  final String avatar;
  final String banner;
  final String collectionId;

  const ProfileImage({
    super.key,
    required this.userId,
    required this.avatar,
    required this.banner,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner image
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: Avatar.getUserImage(
                userId: userId,
                image: banner,
                collectionId: collectionId,
              ),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: CachedNetworkImageProvider(
                  Avatar.getUserImage(
                    userId: userId,
                    image: avatar,
                    collectionId: collectionId,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
