extension HtmlString on String {
  /// Removes all HTML tags from a string.
  /// This method removes all HTML tags and replaces <br> with newline.
  /// Example:
  /// ```dart
  /// String htmlString = '<p>Hello, <b>world</b>!<br>How are you?</p>';
  /// String cleanedString = htmlString.removeAllHtmlTags();
  /// print(cleanedString); // Output: Hello, world!\nHow are you?
  /// ```
  ///
  /// Returns a string with all HTML tags removed.
  String removeAllHtmlTags() {
    // Replace <br> with newline
    String cleanedString = replaceAll(RegExp(r'<br\s*/?>'), '\n');

    // Remove other HTML tags
    cleanedString = cleanedString.replaceAll(RegExp(r'<[^>]*>'), '');

    return cleanedString;
  }
}

extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  /// Example:
  /// ```dart
  /// String name = 'john doe';
  /// String capitalized = name.capitalize();
  /// print(capitalized); // Output: John doe
  /// ```
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
