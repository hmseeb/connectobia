class Avatar {
  static String getAvatarPlaceholder(String firstName, String lastName) {
    return 'https://ui-avatars.com/api/?background=F1F5F9&name=$firstName+$lastName';
  }

  static String getBannerPlaceholder() {
    return 'https://via.assets.so/img.jpg?w=400&h=300&tc=#A9A9A9&bg=grey';
  }

  static String getUserImage({required String id, required String image}) {
    return 'https://connectobia.pockethost.io/api/files/_pb_users_auth_/$id/$image';
  }
}
