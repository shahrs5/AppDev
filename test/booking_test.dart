import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iba_assignments/core/slots.dart';
import 'package:iba_assignments/features/booking/domain/booking.dart';
import 'package:iba_assignments/features/booking/domain/booking_repository.dart';
import 'package:iba_assignments/features/booking/domain/booking_rules.dart';
import 'package:iba_assignments/features/booking/domain/room.dart';
import 'package:iba_assignments/features/booking/presentation/booking_providers.dart';

class FakeBookingRepository implements BookingRepository {
  final List<Booking> bookings = [];
  int _next = 0;

  @override
  Future<void> book({
    required String roomId,
    required DateTime slotStart,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();
    BookingRules.checkNotStarted(slotStart, now);
    final taken = bookings.any((b) =>
        b.roomId == roomId && b.slotStart == slotStart && b.status == 'active');
    BookingRules.checkSlotFree(taken);
    final mine = bookings.where((b) => b.userId == userId && b.isLive(now)).length;
    BookingRules.checkLimit(mine);
    bookings.add(Booking(
      id: 'b${_next++}',
      roomId: roomId,
      date: Slots.dateKey(slotStart),
      slotStart: slotStart,
      slotEnd: Slots.endOf(slotStart),
      userId: userId,
      userName: userName,
      status: 'active',
    ));
  }

  @override
  Future<void> cancel(Booking booking, {bool force = false}) async {
    final i = bookings.indexWhere((b) => b.id == booking.id);
    bookings[i] = bookings[i].copyWith(status: 'cancelled');
  }

  @override
  Stream<List<Room>> watchRooms() => const Stream.empty();

  @override
  Stream<List<Booking>> watchRoomDay(String roomId, String date) => const Stream.empty();

  @override
  Stream<List<Booking>> watchMyUpcoming(String userId) => const Stream.empty();

  @override
  Future<PastPage> fetchMyPast(String userId, {Object? after, int limit = 10}) async {
    return const PastPage([], null, false);
  }
}

void main() {
  late FakeBookingRepository repo;
  late ProviderContainer container;
  final tomorrow = Slots.dayOnly(DateTime.now()).add(const Duration(days: 1));
  final slots = Slots.startsFor(tomorrow);

  setUp(() {
    repo = FakeBookingRepository();
    container = ProviderContainer(overrides: [bookingRepositoryProvider.overrideWithValue(repo)]);
  });

  tearDown(() => container.dispose());

  BookingController controller() => container.read(bookingControllerProvider.notifier);

  test('booking a free slot works', () async {
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u1', userName: 'Ali');
    expect(container.read(bookingControllerProvider).hasError, false);
    expect(repo.bookings.length, 1);
  });

  test('slot already taken gives SlotTakenException', () async {
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u1', userName: 'Ali');
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u2', userName: 'Sara');
    final state = container.read(bookingControllerProvider);
    expect(state.error, isA<SlotTakenException>());
    expect(repo.bookings.length, 1);
  });

  test('third active booking is blocked', () async {
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u1', userName: 'Ali');
    await controller().book(roomId: 'r2', slotStart: slots[3], userId: 'u1', userName: 'Ali');
    await controller().book(roomId: 'r3', slotStart: slots[5], userId: 'u1', userName: 'Ali');
    final state = container.read(bookingControllerProvider);
    expect(state.error, isA<BookingLimitException>());
    expect(repo.bookings.length, 2);
  });

  test('cancelling frees the slot and the limit', () async {
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u1', userName: 'Ali');
    await controller().book(roomId: 'r2', slotStart: slots[3], userId: 'u1', userName: 'Ali');
    await controller().cancel(repo.bookings.first);
    await controller().book(roomId: 'r1', slotStart: slots[0], userId: 'u2', userName: 'Sara');
    expect(container.read(bookingControllerProvider).hasError, false);
    await controller().book(roomId: 'r3', slotStart: slots[6], userId: 'u1', userName: 'Ali');
    expect(container.read(bookingControllerProvider).hasError, false);
  });

  test('active booking that already ended shows as expired', () {
    final past = DateTime.now().subtract(const Duration(hours: 2));
    final b = Booking(
      id: 'x',
      roomId: 'r1',
      date: Slots.dateKey(past),
      slotStart: past,
      slotEnd: Slots.endOf(past),
      userId: 'u1',
      userName: 'Ali',
      status: 'active',
    );
    expect(b.displayStatus(DateTime.now()), 'expired');
    expect(b.canCancel(DateTime.now()), false);
  });

  test('there are 24 slots a day', () {
    expect(Slots.startsFor(tomorrow).length, 24);
  });
}
