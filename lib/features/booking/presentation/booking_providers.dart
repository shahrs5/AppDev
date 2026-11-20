import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/slots.dart';
import '../data/firestore_booking_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/room.dart';

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => FirestoreBookingRepository());

final roomsProvider = StreamProvider<List<Room>>((ref) {
  return ref.watch(bookingRepositoryProvider).watchRooms();
});

final roomDayBookingsProvider =
    StreamProvider.family<List<Booking>, (String, String)>((ref, args) {
  final (roomId, date) = args;
  return ref.watch(bookingRepositoryProvider).watchRoomDay(roomId, date);
});

final myUpcomingProvider = StreamProvider.family<List<Booking>, String>((ref, uid) {
  return ref.watch(bookingRepositoryProvider).watchMyUpcoming(uid);
});

class SelectedDate extends Notifier<DateTime> {
  @override
  DateTime build() => Slots.dayOnly(DateTime.now());

  void select(DateTime day) => state = Slots.dayOnly(day);
}

final selectedDateProvider = NotifierProvider<SelectedDate, DateTime>(SelectedDate.new);

class BookingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> book({
    required String roomId,
    required DateTime slotStart,
    required String userId,
    required String userName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(bookingRepositoryProvider).book(
          roomId: roomId,
          slotStart: slotStart,
          userId: userId,
          userName: userName,
        ));
  }

  Future<void> cancel(Booking booking, {bool force = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(bookingRepositoryProvider).cancel(booking, force: force),
    );
  }
}

final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(BookingController.new);

class PastBookingsState {
  const PastBookingsState(this.bookings, this.cursor, this.hasMore, {this.loadingMore = false});

  final List<Booking> bookings;
  final Object? cursor;
  final bool hasMore;
  final bool loadingMore;
}

class PastBookings extends AsyncNotifier<PastBookingsState> {
  PastBookings(this.uid);

  final String uid;

  @override
  Future<PastBookingsState> build() async {
    final page = await ref.read(bookingRepositoryProvider).fetchMyPast(uid);
    return PastBookingsState(page.bookings, page.cursor, page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(PastBookingsState(current.bookings, current.cursor, true, loadingMore: true));
    try {
      final page = await ref
          .read(bookingRepositoryProvider)
          .fetchMyPast(uid, after: current.cursor);
      state = AsyncData(PastBookingsState(
        [...current.bookings, ...page.bookings],
        page.cursor,
        page.hasMore,
      ));
    } catch (e) {
      state = AsyncData(current);
    }
  }
}

final pastBookingsProvider =
    AsyncNotifierProvider.family<PastBookings, PastBookingsState, String>(PastBookings.new);
