extension StringExtensions on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String camelToTitle() {
    if (isEmpty) return this;

    final result = replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match match) => ' ${match.group(0)}',
    );

    return result[0].toUpperCase() + result.substring(1);
  }
}
