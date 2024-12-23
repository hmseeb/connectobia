/// Utility class for date and time operations.
class DateAndTime {
  /// Formats the given [dateTime] to a date string in the format 'dd MMM yyyy'.
  static String formatDateTimeTo12Hour(DateTime dateTime) {
    dateTime = dateTime.toLocal();
    int hour = dateTime.hour;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Handle midnight (0 hour) as 12 AM

    return '$hour:$minute $period';
  }

  /// Formats the given [dateTime] to a date string in the format 'dd MMM yyyy'.
  /// Example: '01 Jan 2022'.
  ///
  /// If [dateTime] is null, returns an empty string.
  static String timeAgo(DateTime dateTime) {
    dateTime = dateTime.toLocal();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'a few seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months months ago';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years years ago';
    }
  }
}
