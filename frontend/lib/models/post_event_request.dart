class PostEventRequest {
  final String title;
  final String? description;
  final DateTime eventDate;
  final List<int> photoBlobIds;

  PostEventRequest({
    required this.title,
    this.description,
    required this.eventDate,
    required this.photoBlobIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'eventDate': eventDate.toUtc().toIso8601String(),
      'photoBlobIds': photoBlobIds,
    };
  }
}
