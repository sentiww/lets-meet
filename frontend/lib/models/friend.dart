class Friend {
  final int id;
  final int userId;
  final int friendId;

  Friend({required this.id, required this.userId, required this.friendId});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['userId'],
      friendId: json['friendId'],
    );
  }
}