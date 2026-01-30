import 'package:intl/intl.dart';

/// Date Formatter Utility
///
/// Provides consistent date formatting across the app
class DateFormatter {
  DateFormatter._(); // Private constructor

  /// Format a date string to "HH:mm dd,MMM" format
  /// Example: "14:30 25,Jan"
  static String format(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat('HH:mm dd,MMM');
      return formatter.format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  /// Format a DateTime object to "HH:mm dd,MMM" format
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    try {
      final formatter = DateFormat('HH:mm dd,MMM');
      return formatter.format(dateTime);
    } catch (e) {
      return '';
    }
  }
}
