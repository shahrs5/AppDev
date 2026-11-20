import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/slots.dart';
import '../booking_providers.dart';

class DatePickerRow extends ConsumerWidget {
  const DatePickerRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    final days = Slots.bookableDates(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('Date: '),
          DropdownButton<DateTime>(
            value: days.contains(selected) ? selected : days.first,
            items: days.map((d) => DropdownMenuItem(value: d, child: Text(Slots.day(d)))).toList(),
            onChanged: (d) {
              if (d != null) ref.read(selectedDateProvider.notifier).select(d);
            },
          ),
        ],
      ),
    );
  }
}
