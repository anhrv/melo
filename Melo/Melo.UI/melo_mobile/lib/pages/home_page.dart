import 'package:flutter/material.dart';
import 'package:melo_mobile/models/recommendations_response.dart';
import 'package:melo_mobile/pages/admin_album_edit_page.dart';
import 'package:melo_mobile/pages/admin_artist_edit_page.dart';
import 'package:melo_mobile/pages/admin_song_edit_page.dart';
import 'package:melo_mobile/services/recommender_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:melo_mobile/widgets/custom_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late RecommenderService _recommendationService;
  late Future<RecommendationResponse?> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommenderService(context);
    _recommendations = _recommendationService.getRecommendations(context);
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
                onTap: () {
                  if (type == 'artist') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminArtistEditPage(artistId: item.id),
                      ),
                    );
                  } else if (type == 'album') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminAlbumEditPage(albumId: item.id),
                      ),
                    );
                  } else if (type == 'song') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminSongEditPage(songId: item.id),
                      ),
                    );
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
                          style: const TextStyle(
                            color: AppColors.white70,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      endDrawer: const UserDrawer(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: FutureBuilder<RecommendationResponse?>(
        future: _recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const Center(child: Text('Failed to load recommendations'));
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
    );
  }
}
