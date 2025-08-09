import 'package:melo_desktop/models/genre_response.dart';
import 'package:melo_desktop/models/artist_response.dart';

class SongResponse {
  final int id;
  final String? dateOfRelease;
  final String? name;
  final String? playtime;
  final int? likeCount;
  final int? viewCount;
  final String? imageUrl;
  final String? audioUrl;
  final List<GenreResponse> genres;
  final List<ArtistResponse> artists;

  SongResponse({
    required this.id,
    this.dateOfRelease,
    this.name,
    this.playtime,
    this.likeCount,
    this.viewCount,
    this.imageUrl,
    this.audioUrl,
    this.genres = const [],
    this.artists = const [],
  });

  factory SongResponse.fromJson(Map<String, dynamic> json) {
    return SongResponse(
      id: json['id'] as int,
      dateOfRelease: json['dateOfRelease'] as String?,
      name: json['name'] as String?,
      playtime: json['playtime'] as String?,
      likeCount: json['likeCount'] as int?,
      viewCount: json['viewCount'] as int?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => ArtistResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
