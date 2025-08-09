import 'package:melo_desktop/models/album_song_response.dart';
import 'package:melo_desktop/models/genre_response.dart';
import 'package:melo_desktop/models/artist_response.dart';

class AlbumResponse {
  final int id;
  final String? dateOfRelease;
  final String? name;
  final String? playtime;
  final int? songCount;
  final int? likeCount;
  final int? viewCount;
  final String? imageUrl;
  final List<GenreResponse> genres;
  final List<ArtistResponse> artists;
  final List<AlbumSongResponse> songs;

  AlbumResponse({
    required this.id,
    this.dateOfRelease,
    this.name,
    this.playtime,
    this.songCount,
    this.likeCount,
    this.viewCount,
    this.imageUrl,
    this.genres = const [],
    this.artists = const [],
    this.songs = const [],
  });

  factory AlbumResponse.fromJson(Map<String, dynamic> json) {
    return AlbumResponse(
      id: json['id'] as int,
      dateOfRelease: json['dateOfRelease'] as String?,
      name: json['name'] as String?,
      playtime: json['playtime'] as String?,
      songCount: json['songCount'] as int?,
      likeCount: json['likeCount'] as int?,
      viewCount: json['viewCount'] as int?,
      imageUrl: json['imageUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => ArtistResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      songs: (json['songs'] as List<dynamic>?)
              ?.map(
                  (e) => AlbumSongResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
