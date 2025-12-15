/// Utility class for date and time formatting
class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime to a readable time string (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }
}

