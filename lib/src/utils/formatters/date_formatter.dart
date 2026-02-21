import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';

/// Utility class for date formatting operations
class DateFormatter {
  DateFormatter._();

  /// Formats a date string to 'dd/MM/yyyy' format
  /// Returns [fallback] if parsing fails
  static String formatDate(String dateString, {String? fallback}) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      if (fallback != null) return fallback;
      // Try to extract date from ISO format
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString;
    }
  }

  /// Formats a date string to 'yyyy-MM-dd' format (ISO date only)
  static String formatDateISO(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString;
    }
  }

  /// Formats a DateTime to 'yyyy-MM-dd' format
  static String dateToISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime to 'dd/MM/yyyy' format
  static String dateToDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formats a DateTime to 'dd/MM/yyyy HH:mm' format
  static String dateTimeToDisplay(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formats a date string to 'dd/MM/yyyy HH:mm' format
  static String formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return dateTimeToDisplay(dateTime);
    } catch (e) {
      return AppStrings.invalidDate;
    }
  }

  /// Parses a date string and returns DateTime, or null if invalid
  static DateTime? tryParse(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses a date string and returns DateTime, or current date if invalid
  static DateTime parseOrNow(String dateString) {
    return tryParse(dateString) ?? DateTime.now();
  }

  /// Returns a date range string in format 'dd/MM/yyyy - dd/MM/yyyy'
  static String formatDateRange(DateTime start, DateTime end) {
    return '${dateToDisplay(start)} - ${dateToDisplay(end)}';
  }

  /// Returns a date range string in ISO format 'yyyy-MM-dd - yyyy-MM-dd'
  static String formatDateRangeISO(DateTime start, DateTime end) {
    return '${dateToISO(start)} to ${dateToISO(end)}';
  }

  /// Converts DateTime to UTC and returns ISO date string
  static String toUtcDateString(DateTime date) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T')[0];
  }

  /// Returns relative time string (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Checks if a date string is valid
  static bool isValidDate(String dateString) {
    return tryParse(dateString) != null;
  }

  /// Returns the start of the day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of the day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
