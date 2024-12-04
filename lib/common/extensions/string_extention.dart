extension HtmlString on String {
  String removeAllHtmlTags() {
    RegExp exp = RegExp(
      r"<[^>]*>",
    );
    return replaceAll(exp, '');
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
