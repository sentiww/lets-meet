class FeedEvent {
  final int eventId;
  final String title;
  final String? description;
  final int createdBy;
  final List<int> photoIds;
  final List<int> participantIds;

  FeedEvent({
    required this.eventId,
    required this.title,
    this.description,
    required this.createdBy,
    required this.photoIds,
    required this.participantIds,
  });

  factory FeedEvent.fromJson(Map<String, dynamic> json) {
    return FeedEvent(
      eventId: json['eventId'],
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'],
      photoIds: List<int>.from(json['photoIds']),
      participantIds: List<int>.from(json['participantIds']),
    );
  }
}
