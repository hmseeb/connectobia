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

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
