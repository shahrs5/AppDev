import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/slots.dart';
import '../../domain/booking.dart';
import '../../domain/room.dart';
import '../booking_providers.dart';
import '../widgets/date_picker_row.dart';

class AdminTab extends ConsumerWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final day = ref.watch(selectedDateProvider);

    return Column(
      children: [
        const DatePickerRow(),
        Expanded(
          child: rooms.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (rooms) => ListView(
              children: rooms.map((r) => _AdminRoom(room: r, day: day)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminRoom extends ConsumerWidget {
  const _AdminRoom({required this.room, required this.day});

  final Room room;
  final DateTime day;

  Future<void> _forceCancel(BuildContext context, WidgetRef ref, Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force cancel?'),
        content: Text('Cancel ${b.userName}\'s booking at ${Slots.time(b.slotStart)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(bookingControllerProvider.notifier).cancel(b, force: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(roomDayBookingsProvider((room.id, Slots.dateKey(day))));
    final now = DateTime.now();

    return ExpansionTile(
      title: Text(room.name),
      subtitle: Text(bookings.when(
        data: (l) => '${l.length} of ${Slots.perDay} slots booked',
        loading: () => 'Loading...',
        error: (e, _) => 'Error',
      )),
      children: bookings.when(
        loading: () => [const LinearProgressIndicator()],
        error: (e, _) => [Text('Error: $e')],
        data: (list) {
          final byStart = {for (final b in list) b.slotStart.millisecondsSinceEpoch: b};
          return Slots.startsFor(day).map((start) {
            final b = byStart[start.millisecondsSinceEpoch];
            return ListTile(
              dense: true,
              leading: Text(Slots.time(start)),
              title: Text(b == null ? 'Free' : '${b.userName} (${b.displayStatus(now)})'),
              trailing: b == null
                  ? null
                  : TextButton(
                      onPressed: () => _forceCancel(context, ref, b),
                      child: const Text('Cancel'),
                    ),
            );
          }).toList();
        },
      ),
    );
  }
}
