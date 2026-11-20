import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/slots.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_rules.dart';
import '../domain/room.dart';

class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');
  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _slots => _db.collection('slots');

  String _slotId(String roomId, DateTime slotStart) {
    final hhmm = '${slotStart.hour.toString().padLeft(2, '0')}${slotStart.minute.toString().padLeft(2, '0')}';
    return '${roomId}_${Slots.dateKey(slotStart)}_$hhmm';
  }

  Booking _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Booking(
      id: doc.id,
      roomId: d['roomId'] as String,
      date: d['date'] as String,
      slotStart: (d['slotStart'] as Timestamp).toDate(),
      slotEnd: (d['slotEnd'] as Timestamp).toDate(),
      userId: d['userId'] as String,
      userName: d['userName'] as String? ?? '',
      status: d['status'] as String,
    );
  }

  @override
  Stream<List<Room>> watchRooms() {
    return _rooms.orderBy('name').snapshots().map((snap) => snap.docs.map((doc) {
          final d = doc.data();
          return Room(
            id: doc.id,
            name: d['name'] as String,
            floor: (d['floor'] as num).toInt(),
            capacity: (d['capacity'] as num).toInt(),
          );
        }).toList());
  }

  @override
  Stream<List<Booking>> watchRoomDay(String roomId, String date) {
    return _bookings
        .where('roomId', isEqualTo: roomId)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<Booking>> watchMyUpcoming(String userId) {
    final today = Timestamp.fromDate(Slots.dayOnly(DateTime.now()));
    return _bookings
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .where('slotStart', isGreaterThanOrEqualTo: today)
        .orderBy('slotStart')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<PastPage> fetchMyPast(String userId, {Object? after, int limit = 10}) async {
    Query<Map<String, dynamic>> q = _bookings
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['active', 'completed', 'expired'])
        .where('slotEnd', isLessThan: Timestamp.now())
        .orderBy('slotEnd', descending: true)
        .limit(limit);
    if (after != null) {
      q = q.startAfterDocument(after as DocumentSnapshot<Map<String, dynamic>>);
    }
    final snap = await q.get();
    final docs = snap.docs;
    return PastPage(
      docs.map(_fromDoc).toList(),
      docs.isEmpty ? after : docs.last,
      docs.length == limit,
    );
  }

  @override
  Future<void> book({
    required String roomId,
    required DateTime slotStart,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();
    BookingRules.checkNotStarted(slotStart, now);
    final slotEnd = Slots.endOf(slotStart);
    final slotRef = _slots.doc(_slotId(roomId, slotStart));
    final bookingRef = _bookings.doc();

    final (taken, active) = await _db.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      final taken = slotSnap.exists && slotSnap.data()!['active'] == true;

      final mine = await _bookings
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .where('slotEnd', isGreaterThan: Timestamp.fromDate(now))
          .get();
      final active = mine.docs.length;

      if (taken || active >= Slots.maxActiveBookings) {
        return (taken, active);
      }

      tx.set(bookingRef, {
        'roomId': roomId,
        'date': Slots.dateKey(slotStart),
        'slotStart': Timestamp.fromDate(slotStart),
        'slotEnd': Timestamp.fromDate(slotEnd),
        'userId': userId,
        'userName': userName,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.set(slotRef, {
        'bookingId': bookingRef.id,
        'userId': userId,
        'active': true,
      });
      return (taken, active);
    });

    BookingRules.checkSlotFree(taken);
    BookingRules.checkLimit(active);
  }

  @override
  Future<void> cancel(Booking booking, {bool force = false}) async {
    if (!force) {
      BookingRules.checkNotStarted(booking.slotStart, DateTime.now());
    }
    final bookingRef = _bookings.doc(booking.id);
    final slotRef = _slots.doc(_slotId(booking.roomId, booking.slotStart));

    await _db.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      tx.update(bookingRef, {'status': 'cancelled'});
      if (slotSnap.exists && slotSnap.data()!['bookingId'] == booking.id) {
        tx.update(slotRef, {'active': false});
      }
    });
  }
}
