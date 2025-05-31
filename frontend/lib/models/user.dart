class User {
  // User's unique ID
  final int id;

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

  // ID of the user's avatar in the system (optional, default 0 if null)
  final int avatarId;

  // Constructor
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.username,
    required this.dateOfBirth,
    this.avatarUrl,
    this.avatarId = 0,
  });

  // Factory constructor to create a User instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0, // domyślnie 0 jeśli brak id
      email: json['email'] ?? 'default@example.com',
      name: json['name'] ?? 'DefaultName',
      surname: json['surname'] ?? 'DefaultSurname',
      username: json['username'] ?? 'defaultUsername',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime(1970, 1, 1), // domyślna data
      avatarUrl: json['avatarUrl'],
      avatarId: json['avatarId'] ?? 0, // domyślne 0 jeśli null
    );
  }

  // Converts the User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
