class GenreResponse {
  final int id;
  final String? name;
  final int? viewCount;
  final String? imageUrl;

  GenreResponse({
    required this.id,
    this.name,
    this.viewCount,
    this.imageUrl,
  });

  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    return GenreResponse(
      id: json['id'],
      name: json['name'],
      viewCount: json['viewCount'],
      imageUrl: json['imageUrl'],
    );
  }
}
