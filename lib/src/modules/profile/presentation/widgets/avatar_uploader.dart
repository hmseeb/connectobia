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
  final String? displayName;

  const AvatarUploader({
    super.key,
    required this.avatarUrl,
    required this.userId,
    required this.collectionId,
    this.isEditable = false,
    this.onAvatarSelected,
    this.size = 120,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract initials for placeholder
    final String initials = displayName != null && displayName!.isNotEmpty
        ? displayName!
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: isEditable ? () => _pickImage(context) : null,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: Avatar.getUserImage(
                          recordId: userId,
                          image: avatarUrl,
                          collectionId: collectionId,
                        ),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            _buildPlaceholderAvatar(context, initials, isDark),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderAvatar(context, initials, isDark),
                      )
                    : _buildPlaceholderAvatar(context, initials, isDark),
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
                    color: Colors.red.shade400,
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

  Widget _buildPlaceholderAvatar(
      BuildContext context, String initials, bool isDark) {
    return Container(
      color: Colors.grey[200],
      child: initials.isNotEmpty
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size / 3,
                  fontWeight: FontWeight.bold,
                  color: ShadColors.primary,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: size / 2.5,
              color: isDark ? ShadColors.light : ShadColors.dark,
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

    if (image != null) {
      // Check file size - maximum 5MB
      final File file = File(image.path);
      final int fileSizeInBytes = await file.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 5) {
        // Show error popup
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('File Too Large'),
                content: const Text('Please select an image smaller than 5MB.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      // If size is valid, proceed with the callback
      if (onAvatarSelected != null) {
        onAvatarSelected!(image);
      }
    }
  }
}

class TemporaryAvatarUploader extends StatelessWidget {
  final XFile? image;
  final Function() onPressed;
  final double size;
  final String? displayName;

  const TemporaryAvatarUploader({
    super.key,
    required this.image,
    required this.onPressed,
    this.size = 120,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract initials for placeholder
    final String initials = displayName != null && displayName!.isNotEmpty
        ? displayName!
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: image != null
                  ? Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderAvatar(context, initials, isDark),
                    )
                  : _buildPlaceholderAvatar(context, initials, isDark),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
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

  Widget _buildPlaceholderAvatar(
      BuildContext context, String initials, bool isDark) {
    return Container(
      color: Colors.grey[200],
      child: initials.isNotEmpty
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size / 3,
                  fontWeight: FontWeight.bold,
                  color: ShadColors.primary,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: size / 2.5,
              color: isDark ? ShadColors.light : ShadColors.dark,
            ),
    );
  }
}
