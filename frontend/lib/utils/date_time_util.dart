class DateTimeUtils {
  static DateTime? fromString(String? dateString) {
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  static String? toIsoString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }
}
