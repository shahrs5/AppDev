import 'package:intl/intl.dart';

class Slots {
  static const int slotMinutes = 30;
  static const int openHour = 9;
  static const int closeHour = 21;
  static const int bookableDays = 7;
  static const int maxActiveBookings = 2;

  static int get perDay => (closeHour - openHour) * 60 ~/ slotMinutes;

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static List<DateTime> startsFor(DateTime day) {
    final base = DateTime(day.year, day.month, day.day, openHour);
    return List.generate(perDay, (i) => base.add(Duration(minutes: i * slotMinutes)));
  }

  static DateTime endOf(DateTime slotStart) => slotStart.add(const Duration(minutes: slotMinutes));

  static List<DateTime> bookableDates(DateTime now) {
    final today = dayOnly(now);
    return List.generate(bookableDays, (i) => today.add(Duration(days: i)));
  }

  static String time(DateTime d) => DateFormat('h:mm a').format(d);

  static String day(DateTime d) => DateFormat('EEE d MMM').format(d);
}
