/// [Avatar] class contains the methods to get the avatar placeholder and user image.
class Avatar {
  /// Returns the placeholder for the avatar.
  static String getAvatarPlaceholder(String fullName) {
    return 'https://ui-avatars.com/api/?background=F1F5F9&name=$fullName';
  }

  /// Returns the placeholder for the banner.
  static String getBannerPlaceholder() {
    return 'https://via.assets.so/img.jpg?w=400&h=300&tc=#A9A9A9&bg=grey';
  }

  /// Returns the user image.
  static String getUserImage(
      {required String recordId,
      required String image,
      required String collectionId}) {
    return 'https://connectobia.pockethost.io/api/files/$collectionId/$recordId/$image';
  }
}
