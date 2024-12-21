extension HtmlString on String {
  String removeAllHtmlTags() {
    // Replace <br> with newline
    String cleanedString = replaceAll(RegExp(r'<br\s*/?>'), '\n');

    // Remove other HTML tags
    cleanedString = cleanedString.replaceAll(RegExp(r'<[^>]*>'), '');

    return cleanedString;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
