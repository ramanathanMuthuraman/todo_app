import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final pickedDate = DateTime(date.year, date.month, date.day);

  if (pickedDate == today) return "Today";
  if (pickedDate == tomorrow) return "Tomorrow";

  return DateFormat('E, MMM d').format(date); // Example: Mon, Feb 12
}

String formatTime(DateTime dt) {
  return DateFormat('h:mm a').format(dt); // 6:30 PM
}

String timeLeftText(DateTime due) {
  final now = DateTime.now();
  final diff = due.difference(now);

  if (diff.inSeconds.abs() < 60) return diff.isNegative ? 'overdue' : 'now';

  // If overdue
  if (diff.isNegative) {
    final h = diff.inHours.abs();
    final m = diff.inMinutes.abs() % 60;
    if (h > 0) return 'overdue ${h}h ${m}m';
    return 'overdue ${m}m';
  }

  // If upcoming
  if (diff.inDays >= 1) return 'in ${diff.inDays}d';
  if (diff.inHours >= 1) return 'in ${diff.inHours}h';
  return 'in ${diff.inMinutes}m';
}
