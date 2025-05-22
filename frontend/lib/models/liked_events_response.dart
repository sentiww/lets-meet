class LikedEventsResponse {
  final List<LikedEvent> events;

  LikedEventsResponse({required this.events});

  factory LikedEventsResponse.fromJson(Map<String, dynamic> json) {
    return LikedEventsResponse(
      events: (json['events'] as List)
          .map((e) => LikedEvent.fromJson(e))
          .toList(),
    );
  }
}

class LikedEvent {
  final int eventId;

  LikedEvent({required this.eventId});

  factory LikedEvent.fromJson(Map<String, dynamic> json) {
    return LikedEvent(eventId: json['eventId']);
  }
}
