class PlaylistResponse {
  final int id;
  final String? name;
  final int? songCount;
  final String? playtime;

  PlaylistResponse({
    required this.id,
    this.name,
    this.songCount,
    this.playtime,
  });

  factory PlaylistResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistResponse(
      id: json['id'],
      name: json['name'],
      songCount: json['songCount'],
      playtime: json['playtime'],
    );
  }
}
