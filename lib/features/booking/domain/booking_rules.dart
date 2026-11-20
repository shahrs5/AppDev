import '../../../core/slots.dart';

class SlotTakenException implements Exception {
  @override
  String toString() => 'Someone just booked this — pick another slot';
}

class BookingLimitException implements Exception {
  @override
  String toString() =>
      'You already have ${Slots.maxActiveBookings} active bookings. Cancel one or wait for it to finish.';
}

class TooLateException implements Exception {
  TooLateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BookingRules {
  static void checkSlotFree(bool taken) {
    if (taken) throw SlotTakenException();
  }

  static void checkLimit(int activeCount) {
    if (activeCount >= Slots.maxActiveBookings) throw BookingLimitException();
  }

  static void checkNotStarted(DateTime slotStart, DateTime now) {
    if (!slotStart.isAfter(now)) {
      throw TooLateException('That slot has already started');
    }
  }
}
