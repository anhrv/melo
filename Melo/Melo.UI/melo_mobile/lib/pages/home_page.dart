import 'package:flutter/material.dart';
import 'package:melo_mobile/models/recommendations_response.dart';
import 'package:melo_mobile/models/song_response.dart';
import 'package:melo_mobile/pages/album_page.dart';
import 'package:melo_mobile/pages/artist_page.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/services/recommender_service.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/app_shell.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AudioPlayerService _audioPlayer;
  late RecommenderService _recommendationService;
  late Future<RecommendationResponse?> _recommendations;

  @override
  void initState() {
    super.initState();
    _audioPlayer = context.read<AudioPlayerService>();
    _audioPlayer.addListener(() {
      if (mounted) setState(() {});
    });
    _recommendationService = RecommenderService(context);
    _recommendations = _recommendationService.getRecommendations(context);
  }

  @override
  void dispose() {
    _audioPlayer.removeListener(() {});
    super.dispose();
  }

  Widget _buildImageContent(String? imageUrl, IconData icon) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 175,
          height: 150,
          color: Colors.grey,
          child: Icon(icon, size: 40),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 175,
      height: 150,
      borderRadius: 8,
      iconData: icon,
      iconSize: 40,
    );
  }

  Widget _buildCarousel(String title, List items, String type, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(color: AppColors.white54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = item.imageUrl;

              final String titleText;
              final String subtitleText;

              if (type == 'artist') {
                titleText = item.name ?? '';
                subtitleText = '';
              } else {
                titleText = item.name ?? '';
                final artists = item.artists ?? [];
                subtitleText = artists.map((a) => a.name).join(', ');
              }

              return GestureDetector(
                onTap: () async {
                  if (type == 'artist') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtistPage(
                          artistId: item.id,
                          currentIndex: 1,
                        ),
                      ),
                    );
                  } else if (type == 'album') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlbumPage(
                          albumId: item.id,
                          currentIndex: 1,
                        ),
                      ),
                    );
                  } else if (type == 'song') {
                    if (item.audioUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Song audio not available'),
                          backgroundColor: AppColors.redAccent,
                        ),
                      );
                      return;
                    }

                    final token = await TokenStorage.getAccessToken();
                    final currentSong = _audioPlayer.currentSong;

                    if (currentSong?.audioUrl == item.audioUrl) {
                      _audioPlayer.togglePlayback();
                    } else {
                      _audioPlayer.playSong(
                        item,
                        context,
                        headers: {'Authorization': 'Bearer $token'},
                      );
                    }
                  }
                },
                child: SizedBox(
                  width: 175,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageContent(imageUrl, icon),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: type == 'song' && _isCurrentSong(item)
                                ? AppColors.secondary
                                : AppColors.white70,
                          ),
                        ),
                      ),
                      if (subtitleText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
          ),
        ),
      ],
    );
  }

  bool _isCurrentSong(SongResponse song) {
    return _audioPlayer.currentSong?.audioUrl != null &&
        song.audioUrl != null &&
        _audioPlayer.currentSong?.audioUrl == song.audioUrl;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Scaffold(
        appBar: const CustomAppBar(),
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
        body: FutureBuilder<RecommendationResponse?>(
          future: _recommendations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(
                  child: Text('Failed to load recommendations'));
            }

            final songs = snapshot.data!.songs;
            final albums = snapshot.data!.albums;
            final artists = snapshot.data!.artists;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (songs.isNotEmpty)
                  _buildCarousel(
                      'Recommended songs', songs, 'song', Icons.music_note),
                if (albums.isNotEmpty)
                  _buildCarousel(
                      'Recommended albums', albums, 'album', Icons.album),
                if (artists.isNotEmpty)
                  _buildCarousel(
                      'Recommended artists', artists, 'artist', Icons.mic),
              ],
            );
          },
        ),
      ),
    );
  }
}
