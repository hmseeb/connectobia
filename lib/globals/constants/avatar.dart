class UserAvatar {
  static String getAvatarUrl(String firstName, String lastName) {
    return 'https://ui-avatars.com/api/?background=F1F5F9&name=$firstName+$lastName';
  }
}
