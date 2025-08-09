import 'package:melo_desktop/models/artist_response.dart';
import 'package:melo_desktop/models/genre_response.dart';

import 'song_response.dart';

class AlbumSongResponse extends SongResponse {
  final int? songOrder;

  AlbumSongResponse({
    required super.id,
    super.dateOfRelease,
    super.name,
    super.playtime,
    super.likeCount,
    super.viewCount,
    super.imageUrl,
    super.audioUrl,
    super.genres,
    super.artists,
    this.songOrder,
  });

  factory AlbumSongResponse.fromJson(Map<String, dynamic> json) {
    return AlbumSongResponse(
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
      songOrder: json['songOrder'] as int?,
    );
  }
}
