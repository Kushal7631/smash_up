class Slot {
  final int id;
  final int venueId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final int? bookedBy;

  Slot({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    this.bookedBy,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      venueId: json['venue_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isBooked: json['is_booked'] ?? false,
      bookedBy: json['booked_by'],
    );
  }

  /// Format start_time for display (e.g., "06:00" → "6:00 AM")
  String get displayTime {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${parts[1]} $period';
  }

  String get displayEndTime {
    final parts = endTime.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${parts[1]} $period';
  }
}
