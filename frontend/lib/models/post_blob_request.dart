class PostBlobRequest {
  final String name;
  final String extension;
  final String contentType;
  final List<int> data;

  PostBlobRequest({
    required this.name,
    required this.extension,
    required this.contentType,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extension': extension,
      'contentType': contentType,
      'data': data,
    };
  }
}
