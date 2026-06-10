class Booking {
  final int id;
  final int slotId;
  final int userId;
  final String createdAt;
  final String? venueName;
  final String? sport;
  final String? date;
  final String? startTime;
  final String? endTime;

  Booking({
    required this.id,
    required this.slotId,
    required this.userId,
    required this.createdAt,
    this.venueName,
    this.sport,
    this.date,
    this.startTime,
    this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      slotId: json['slot_id'],
      userId: json['user_id'],
      createdAt: json['created_at'] ?? '',
      venueName: json['venue_name'],
      sport: json['sport'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  /// Format start_time for display
  String get displayTime {
    if (startTime == null) return '';
    final parts = startTime!.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${parts[1]} $period';
  }

  String get displayEndTime {
    if (endTime == null) return '';
    final parts = endTime!.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${parts[1]} $period';
  }
}
