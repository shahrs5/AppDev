import 'booking.dart';
import 'room.dart';

class PastPage {
  const PastPage(this.bookings, this.cursor, this.hasMore);

  final List<Booking> bookings;
  final Object? cursor;
  final bool hasMore;
}

abstract class BookingRepository {
  Stream<List<Room>> watchRooms();

  Stream<List<Booking>> watchRoomDay(String roomId, String date);

  Stream<List<Booking>> watchMyUpcoming(String userId);

  Future<PastPage> fetchMyPast(String userId, {Object? after, int limit = 10});

  Future<void> book({
    required String roomId,
    required DateTime slotStart,
    required String userId,
    required String userName,
  });

  Future<void> cancel(Booking booking, {bool force = false});
}
