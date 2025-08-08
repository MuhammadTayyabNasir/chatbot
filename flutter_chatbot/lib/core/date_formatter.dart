import 'package:intl/intl.dart';

// For message grouping by day, used in the UI layer
String formatDisplayDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (date.isAtSameMomentAs(today)) {
    return "Today";
  } else if (date.isAtSameMomentAs(yesterday)) {
    return "Yesterday";
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

// For Check-in plan date display
String formatDisplayDateChckIns(DateTime date) {
  return DateFormat('MMMM d, yyyy').format(date);
}

// For message timestamp
String formatDisplayTime(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}