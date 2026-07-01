import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

import 'package:shreshtlibrary/features/seats/interactive_seat_map.dart';

final seatsProvider = FutureProvider.autoDispose<List<Seat>>(
  (ref) => ref.watch(studentApiProvider).seats(),
);
final seatHistoryProvider = FutureProvider.autoDispose<List<SeatAssignment>>(
  (ref) => ref.watch(studentApiProvider).seatHistory(),
);

class SeatsScreen extends ConsumerWidget {
  const SeatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Seats',
      onRefresh: () async {
        ref.invalidate(seatsProvider);
        ref.invalidate(seatHistoryProvider);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
              title: 'Seat Layout',
              child: AsyncPane(
                value: ref.watch(seatsProvider),
                builder: (seats) => seats.isEmpty
                    ? const Text('No seats configured.')
                    : InteractiveSeatMap(seats: seats),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'My Seat History',
              child: AsyncPane(
                value: ref.watch(seatHistoryProvider),
                builder: (rows) => rows.isEmpty
                    ? const Text('No seat assignment history.')
                    : Column(
                        children: rows
                            .map(
                              (row) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.event_seat_outlined),
                                title: Text(row.seatDetails),
                                subtitle: Text(
                                  'Assigned ${row.assignedDate}${row.releasedDate == null ? '' : ' - Released ${row.releasedDate}'}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
    );
  }
}

