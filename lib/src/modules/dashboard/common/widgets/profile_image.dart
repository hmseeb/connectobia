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

  const ProfileImage({
    super.key,
    required this.userId,
    required this.avatar,
    required this.banner,
    required this.collectionId,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
              )),
          Positioned(
            bottom: 0,
            left: 10,
            child: Center(
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: CachedNetworkImageProvider(
                    avatar.isNotEmpty
                        ? Avatar.getUserImage(
                            recordId: userId,
                            image: avatar,
                            collectionId: collectionId,
                          )
                        : Avatar.getAvatarPlaceholder('HA'),
                  )),
            ),
          ),
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
