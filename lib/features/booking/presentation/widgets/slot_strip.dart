import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/slots.dart';
import '../../domain/booking.dart';
import '../../domain/room.dart';
import '../booking_providers.dart';

class SlotStrip extends ConsumerWidget {
  const SlotStrip({
    super.key,
    required this.room,
    required this.day,
    required this.myUid,
    required this.onSlotTap,
  });

  final Room room;
  final DateTime day;
  final String myUid;
  final void Function(DateTime slotStart, Booking? booking) onSlotTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(roomDayBookingsProvider((room.id, Slots.dateKey(day))));
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${room.name}  •  Floor ${room.floor}  •  ${room.capacity} seats',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            bookings.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                final byStart = {for (final b in list) b.slotStart.millisecondsSinceEpoch: b};
                return Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: Slots.startsFor(day).map((start) {
                    final b = byStart[start.millisecondsSinceEpoch];
                    Color color;
                    if (b != null) {
                      color = b.userId == myUid ? Colors.blue : Colors.red;
                    } else if (!start.isAfter(now)) {
                      color = Colors.grey.shade300;
                    } else {
                      color = Colors.green;
                    }
                    return Tooltip(
                      message: Slots.time(start),
                      child: GestureDetector(
                        onTap: () => onSlotTap(start, b),
                        child: Container(width: 12, height: 22, color: color),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
