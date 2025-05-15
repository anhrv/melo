import 'package:melo_mobile/models/album_response.dart';
import 'package:melo_mobile/models/artist_response.dart';
import 'package:melo_mobile/models/song_response.dart';

class RecommendationResponse {
  final List<SongResponse> songs;
  final List<AlbumResponse> albums;
  final List<ArtistResponse> artists;

  RecommendationResponse({
    required this.songs,
    required this.albums,
    required this.artists,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      songs:
          (json['songs'] as List).map((e) => SongResponse.fromJson(e)).toList(),
      albums: (json['albums'] as List)
          .map((e) => AlbumResponse.fromJson(e))
          .toList(),
      artists: (json['artists'] as List)
          .map((e) => ArtistResponse.fromJson(e))
          .toList(),
    );
  }
}
