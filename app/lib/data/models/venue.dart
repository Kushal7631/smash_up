class Venue {
  final int id;
  final String name;
  final String sport;
  final String location;

  Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.location,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      sport: json['sport'],
      location: json['location'],
    );
  }
}
