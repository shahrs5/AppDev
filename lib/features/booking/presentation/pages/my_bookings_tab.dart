import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/slots.dart';
import '../../../auth/domain/app_user.dart';
import '../../domain/booking.dart';
import '../../domain/room.dart';
import '../booking_providers.dart';

class MyBookingsTab extends ConsumerWidget {
  const MyBookingsTab({super.key, required this.user});

  final AppUser user;

  String _roomName(List<Room> rooms, String id) {
    for (final r in rooms) {
      if (r.id == id) return r.name;
    }
    return id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(myUpcomingProvider(user.uid));
    final past = ref.watch(pastBookingsProvider(user.uid));
    final rooms = ref.watch(roomsProvider).value ?? [];
    final now = DateTime.now();

    Widget tile(Booking b, {bool cancellable = false}) {
      return ListTile(
        title: Text(_roomName(rooms, b.roomId)),
        subtitle: Text('${Slots.day(b.slotStart)}, ${Slots.time(b.slotStart)} - ${Slots.time(b.slotEnd)}'),
        trailing: cancellable && b.canCancel(now)
            ? TextButton(
                onPressed: () => ref.read(bookingControllerProvider.notifier).cancel(b),
                child: const Text('Cancel'),
              )
            : Text(b.displayStatus(now)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pastBookingsProvider(user.uid)),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Upcoming', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          upcoming.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(padding: const EdgeInsets.all(12), child: Text('Error: $e')),
            data: (list) {
              final live = list.where((b) => b.isLive(now)).toList();
              if (live.isEmpty) {
                return const Padding(padding: EdgeInsets.all(12), child: Text('No upcoming bookings'));
              }
              return Column(children: live.map((b) => tile(b, cancellable: true)).toList());
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Past', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          past.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(padding: const EdgeInsets.all(12), child: Text('Error: $e')),
            data: (state) {
              return Column(
                children: [
                  if (state.bookings.isEmpty)
                    const Padding(padding: EdgeInsets.all(12), child: Text('Nothing here yet')),
                  ...state.bookings.map((b) => tile(b)),
                  if (state.hasMore)
                    TextButton(
                      onPressed: state.loadingMore
                          ? null
                          : () => ref.read(pastBookingsProvider(user.uid).notifier).loadMore(),
                      child: Text(state.loadingMore ? 'Loading...' : 'Load more'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
