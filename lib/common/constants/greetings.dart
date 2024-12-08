class Greetings {
  static const String morning = 'Good Morning';
  static const String afternoon = 'Good Afternoon';
  static const String evening = 'Good Evening';

  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '$morning, $name!';
    } else if (hour < 17) {
      return '$afternoon, $name!';
    } else {
      return '$evening, $name!';
    }
  }
}
