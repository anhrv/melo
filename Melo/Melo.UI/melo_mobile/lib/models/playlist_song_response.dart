import 'package:melo_mobile/models/artist_response.dart';
import 'package:melo_mobile/models/genre_response.dart';

import 'song_response.dart';

class PlaylistSongResponse extends SongResponse {
  final int? songOrder;

  PlaylistSongResponse({
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

  factory PlaylistSongResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistSongResponse(
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
