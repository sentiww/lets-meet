class BlobInfo {
  final int id;
  final String name;

  BlobInfo({
    required this.id,
    required this.name,
  });

  factory BlobInfo.fromJson(Map<String, dynamic> json) {
    return BlobInfo(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
