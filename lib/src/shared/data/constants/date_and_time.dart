import 'package:intl/intl.dart';

/// Utility class for date and time operations.
class DateAndTime {
  /// Formats the given [dateTime] to a date string in the specified format.
  /// Uses the intl package's DateFormat for reliable date formatting.
  ///
  /// Examples:
  /// - 'MMM dd, yyyy' for 'Jan 01, 2023'
  /// - 'yyyy-MM-dd' for '2023-01-01'
  /// - 'EEEE, MMMM d' for 'Monday, January 1'
  ///
  /// If [dateTime] is null, returns an empty string.
  static String formatDate(DateTime? dateTime, String format) {
    if (dateTime == null) return '';
    return DateFormat(format).format(dateTime);
  }

  /// Formats the given [dateTime] to a time string in the format 'h:mm AM/PM'.
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

  /// Returns a human-readable string representing time elapsed since [dateTime].
  /// Example: '5 minutes ago', '2 hours ago', '3 days ago'.
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
