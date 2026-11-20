import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../booking_providers.dart';
import 'admin_tab.dart';
import 'my_bookings_tab.dart';
import 'rooms_tab.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(bookingControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      final messenger = ScaffoldMessenger.of(context);
      if (next.hasError) {
        messenger.showSnackBar(SnackBar(content: Text(next.error.toString())));
      } else if (next.hasValue) {
        messenger.showSnackBar(const SnackBar(content: Text('Done')));
        ref.invalidate(pastBookingsProvider(user.uid));
      }
    });

    final tabs = [
      const Tab(text: 'Rooms'),
      const Tab(text: 'My Bookings'),
      if (user.isAdmin) const Tab(text: 'Admin'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('RoomBook - ${user.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
          bottom: TabBar(tabs: tabs),
        ),
        body: TabBarView(
          children: [
            RoomsTab(user: user),
            MyBookingsTab(user: user),
            if (user.isAdmin) const AdminTab(),
          ],
        ),
      ),
    );
  }
}
