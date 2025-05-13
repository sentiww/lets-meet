class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final List<String>? photoIds;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.eventDate,
    this.photoIds,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : null,
      photoIds: json['photoIds'] != null
          ? List<String>.from(json['photoIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate?.toIso8601String(),
      'photoIds': photoIds,
    };
  }
}
