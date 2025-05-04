import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/data/constants/avatar.dart';
import '../../../../theme/colors.dart';

class BannerUploader extends StatelessWidget {
  final String bannerUrl;
  final String userId;
  final String collectionId;
  final bool isEditable;
  final Function(XFile)? onBannerSelected;
  final double height;

  const BannerUploader({
    super.key,
    required this.bannerUrl,
    required this.userId,
    required this.collectionId,
    this.isEditable = false,
    this.onBannerSelected,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: bannerUrl.isNotEmpty
                      ? Avatar.getUserImage(
                          recordId: userId,
                          image: bannerUrl,
                          collectionId: collectionId,
                        )
                      : Avatar.getBannerPlaceholder(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: ShadColors.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                if (isEditable && bannerUrl.isEmpty)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: Text(
                          "Add a banner image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isEditable)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ShadColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera,
                  size: 20,
                  color: ShadColors.light,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    if (!isEditable) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, // Higher resolution for banner
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null && onBannerSelected != null) {
      onBannerSelected!(image);
    }
  }
}

class TemporaryBannerUploader extends StatelessWidget {
  final XFile? image;
  final Function() onPressed;
  final double height;

  const TemporaryBannerUploader({
    super.key,
    required this.image,
    required this.onPressed,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                image != null
                    ? Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Preview not available",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ShadColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.photo_camera,
                size: 20,
                color: ShadColors.light,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
