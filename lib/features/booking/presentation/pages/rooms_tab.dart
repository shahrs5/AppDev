import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/slots.dart';
import '../../../auth/domain/app_user.dart';
import '../../domain/booking.dart';
import '../../domain/room.dart';
import '../booking_providers.dart';
import '../widgets/date_picker_row.dart';
import '../widgets/slot_strip.dart';

class RoomsTab extends ConsumerWidget {
  const RoomsTab({super.key, required this.user});

  final AppUser user;

  Future<void> _onTap(BuildContext context, WidgetRef ref, Room room, DateTime start, Booking? b) async {
    if (b != null) {
      final who = b.userId == user.uid ? 'you' : 'someone else';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Slots.time(start)} is booked by $who')),
      );
      return;
    }
    if (!start.isAfter(DateTime.now())) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book this slot?'),
        content: Text('${room.name}\n${Slots.day(start)}, ${Slots.time(start)} - ${Slots.time(Slots.endOf(start))}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Book')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(bookingControllerProvider.notifier).book(
          roomId: room.id,
          slotStart: start,
          userId: user.uid,
          userName: user.name,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final day = ref.watch(selectedDateProvider);
    final busy = ref.watch(bookingControllerProvider).isLoading;

    return Column(
      children: [
        const DatePickerRow(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Green = free, Red = taken, Blue = yours. Each box is 30 min from 9 AM.'),
        ),
        if (busy) const LinearProgressIndicator(),
        Expanded(
          child: rooms.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Could not load rooms: $e')),
            data: (rooms) {
              if (rooms.isEmpty) return const Center(child: Text('No rooms yet'));
              return ListView(
                padding: const EdgeInsets.all(8),
                children: rooms
                    .map((room) => SlotStrip(
                          room: room,
                          day: day,
                          myUid: user.uid,
                          onSlotTap: (start, b) => _onTap(context, ref, room, start, b),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
