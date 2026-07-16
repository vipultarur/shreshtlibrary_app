import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/models/models.dart';

class InteractiveSeatMap extends StatefulWidget {
  const InteractiveSeatMap({super.key, required this.seats});
  final List<Seat> seats;

  @override
  State<InteractiveSeatMap> createState() => _InteractiveSeatMapState();
}

class _InteractiveSeatMapState extends State<InteractiveSeatMap> {
  String? _selectedFloor;

  @override
  void initState() {
    super.initState();
    if (widget.seats.isNotEmpty) {
      // Find all unique floors
      final floors = widget.seats.map((e) => e.floor).toSet().toList()..sort();
      if (floors.isNotEmpty) {
        _selectedFloor = floors.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seats.isEmpty) {
      return const Center(child: Text('No seats configured.'));
    }

    final floors = widget.seats.map((e) => e.floor).toSet().toList()..sort();

    // Fallback if not set
    _selectedFloor ??= floors.first;

    final floorSeats = widget.seats
        .where((s) => s.floor == _selectedFloor)
        .toList();

    // Group by row
    final Map<String, List<Seat>> rows = {};
    for (final seat in floorSeats) {
      rows.putIfAbsent(seat.row, () => []).add(seat);
    }

    final rowKeys = rows.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Floor selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: floors.map((floor) {
              final isSelected = floor == _selectedFloor;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('Floor $floor'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFloor = floor;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Seat Map legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green.shade400, 'Available'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.red.shade400, 'Occupied'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.orange.shade400, 'Maintenance'),
          ],
        ),
        const SizedBox(height: 16),

        // Interactive Map
        Container(
          height: 350,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: rowKeys.map((rowKey) {
                    final rowSeats = rows[rowKey]!
                      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Row Label
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'Row $rowKey',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ...rowSeats.map((seat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: _InteractiveSeatWidget(seat: seat),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _InteractiveSeatWidget extends StatelessWidget {
  const _InteractiveSeatWidget({required this.seat});

  final Seat seat;

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    final status = seat.status.toLowerCase();
    if (status == 'available') {
      seatColor = Colors.green.shade400;
    } else if (status == 'maintenance') {
      seatColor = Colors.orange.shade400;
    } else {
      seatColor = Colors.red.shade400;
    }

    return Tooltip(
      message: 'Seat ${seat.seatNumber}\nStatus: ${seat.status}',
      child: Container(
        width: 44,
        height: 52,
        decoration: BoxDecoration(
          color: seatColor.withValues(alpha: 0.1),
          border: Border.all(color: seatColor, width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat, color: seatColor, size: 20),
            Text(
              seat.seatNumber,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: seatColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
