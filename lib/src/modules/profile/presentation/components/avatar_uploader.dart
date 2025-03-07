import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/data/constants/avatar.dart';
import '../../../../theme/colors.dart';

class AvatarUploader extends StatelessWidget {
  final String avatarUrl;
  final String userId;
  final String collectionId;
  final bool isEditable;
  final Function(XFile)? onAvatarSelected;
  final double size;

  const AvatarUploader({
    super.key,
    required this.avatarUrl,
    required this.userId,
    required this.collectionId,
    this.isEditable = false,
    this.onAvatarSelected,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: isEditable ? () => _pickImage(context) : null,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ShadColors.primary,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(
                        Avatar.getUserImage(
                          recordId: userId,
                          image: avatarUrl,
                          collectionId: collectionId,
                        ),
                      )
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: size / 2.5,
                        color: isDark ? ShadColors.light : ShadColors.dark,
                      )
                    : null,
              ),
            ),
          ),
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ShadColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: ShadColors.light,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    if (!isEditable) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null && onAvatarSelected != null) {
      onAvatarSelected!(image);
    }
  }
}

class TemporaryAvatarUploader extends StatelessWidget {
  final XFile? image;
  final Function() onPressed;
  final double size;

  const TemporaryAvatarUploader({
    super.key,
    required this.image,
    required this.onPressed,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ShadColors.primary,
                width: 2,
              ),
              image: image != null
                  ? DecorationImage(
                      image: FileImage(File(image!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? Icon(
                    Icons.person,
                    size: size / 2.5,
                    color: isDark ? ShadColors.light : ShadColors.dark,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ShadColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: ShadColors.light,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
