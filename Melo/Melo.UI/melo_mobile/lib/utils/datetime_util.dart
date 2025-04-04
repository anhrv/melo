import 'package:intl/intl.dart';

class DateTimeUtil {
  static String formatUtcToLocal(
    String utcDateTimeString, {
    String format = 'dd MMM yyyy, HH:mm',
  }) {
    final parts = utcDateTimeString.split('.');
    final dateTimePart = parts[0];
    String fractional = parts[1];

    if (fractional.length > 6) {
      fractional = fractional.substring(0, 6);
    }

    final utcDateTime = DateTime.parse(
        '$dateTimePart.$fractional${fractional.isNotEmpty ? 'Z' : ''}');

    final localDateTime = utcDateTime.toLocal();
    return DateFormat(format).format(localDateTime);
  }
}
