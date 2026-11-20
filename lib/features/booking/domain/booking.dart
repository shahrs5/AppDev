class Booking {
  const Booking({
    required this.id,
    required this.roomId,
    required this.date,
    required this.slotStart,
    required this.slotEnd,
    required this.userId,
    required this.userName,
    required this.status,
  });

  final String id;
  final String roomId;
  final String date;
  final DateTime slotStart;
  final DateTime slotEnd;
  final String userId;
  final String userName;
  final String status;

  bool isExpired(DateTime now) => status == 'active' && slotEnd.isBefore(now);

  String displayStatus(DateTime now) => isExpired(now) ? 'expired' : status;

  bool isLive(DateTime now) => status == 'active' && slotEnd.isAfter(now);

  bool canCancel(DateTime now) => status == 'active' && slotStart.isAfter(now);

  Booking copyWith({String? status}) {
    return Booking(
      id: id,
      roomId: roomId,
      date: date,
      slotStart: slotStart,
      slotEnd: slotEnd,
      userId: userId,
      userName: userName,
      status: status ?? this.status,
    );
  }
}
