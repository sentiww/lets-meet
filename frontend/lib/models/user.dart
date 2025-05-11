class User {
  // User's email address
  final String email;

  // User's first name
  final String name;

  // User's last name
  final String surname;

  // User's username
  final String username;

  // User's date of birth
  final DateTime dateOfBirth;

  // URL to the user's avatar image (optional)
  final String? avatarUrl;

  // ID of the user's avatar in the system (optional)
  final int? avatarId;

  // Constructor
  User({
    required this.email,
    required this.name,
    required this.surname,
    required this.username,
    required this.dateOfBirth,
    this.avatarUrl,
    this.avatarId,
  });

  // Factory constructor to create a User instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      avatarUrl: json['avatarUrl'],
      avatarId: json['avatarId'],
    );
  }

  // Converts the User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'username': username,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'avatarUrl': avatarUrl,
      'avatarId': avatarId,
    };
  }

  // Returns the formatted date of birth as a string (DD.MM.YYYY)
  String get formattedDate =>
      "${dateOfBirth.day.toString().padLeft(2, '0')}.${dateOfBirth.month.toString().padLeft(2, '0')}.${dateOfBirth.year}";
}
