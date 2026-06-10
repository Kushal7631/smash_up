import 'package:flutter/material.dart';
import '../../data/models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Sport icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getSportIcon(booking.sport),
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.venueName ?? 'Venue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.date ?? ''} · ${booking.displayTime} - ${booking.displayEndTime}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Cancel button
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: 'Cancel Booking',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSportIcon(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return Icons.sports_tennis;
      case 'football':
        return Icons.sports_soccer;
      case 'cricket':
        return Icons.sports_cricket;
      default:
        return Icons.sports;
    }
  }
}
