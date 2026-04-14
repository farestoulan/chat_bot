import 'package:flutter/widgets.dart';

/// Helper for detecting text direction based on content language.
class TextDirectionHelper {
  static final _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  /// Returns true if the text is predominantly Arabic / RTL.
  static bool isArabic(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final firstChar = trimmed.runes.first;
    if ((firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF) ||
        (firstChar >= 0xFB50 && firstChar <= 0xFDFF) ||
        (firstChar >= 0xFE70 && firstChar <= 0xFEFF)) {
      return true;
    }

    final stripped = text.replaceAll(RegExp(r'\s+'), '');
    if (stripped.isEmpty) return false;
    final arabicCount = _arabicRegex.allMatches(stripped).length;
    return arabicCount > stripped.length / 4;
  }

  /// Returns the appropriate [TextDirection] for the given text.
  static TextDirection getTextDirection(String text) =>
      isArabic(text) ? TextDirection.rtl : TextDirection.ltr;

  /// Returns the appropriate [TextAlign] for the given text.
  static TextAlign getTextAlign(String text) =>
      isArabic(text) ? TextAlign.right : TextAlign.left;

  /// Returns the appropriate [CrossAxisAlignment] for the given text.
  static CrossAxisAlignment getCrossAxisAlignment(String text) =>
      isArabic(text) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
}
