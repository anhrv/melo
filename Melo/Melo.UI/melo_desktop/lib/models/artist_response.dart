import 'package:melo_desktop/models/genre_response.dart';

class ArtistResponse {
  final int id;
  final String? name;
  final int? likeCount;
  final int? viewCount;
  final String? imageUrl;
  final List<GenreResponse> genres;

  ArtistResponse({
    required this.id,
    this.name,
    this.likeCount,
    this.viewCount,
    this.imageUrl,
    this.genres = const [],
  });

  factory ArtistResponse.fromJson(Map<String, dynamic> json) {
    return ArtistResponse(
      id: json['id'] as int,
      name: json['name'] as String?,
      likeCount: json['likeCount'] as int?,
      viewCount: json['viewCount'] as int?,
      imageUrl: json['imageUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
