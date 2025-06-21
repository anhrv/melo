import 'package:flutter/material.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/genre_response.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/song_response.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/services/playlist_service.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:provider/provider.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  final _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _viewCountController = TextEditingController();
  final TextEditingController _likeCountController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();

  late PlaylistService _playlistService;
  late AuthInterceptor _client;

  List<LovResponse> _selectedPlaylists = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playlistService = Provider.of<PlaylistService>(context, listen: false);
    _client = Provider.of<AuthInterceptor>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context, listen: true);
    final playerState = audioService.playerState;

    final artists =
        audioService.currentSong?.artists.map((a) => a.name).toList();
    final artistsDisplay = artists != null && artists.isNotEmpty
        ? artists.join(', ')
        : "No artists";

    final isLiked = audioService.isLiked;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.expand_more, color: AppColors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                        audioService.collapsePlayer();
                      },
                    ),
                    const Spacer(),
                    _buildMenuButton(audioService.currentSong),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSongImage(audioService.currentSong?.imageUrl),
                const SizedBox(height: 24),
                Text(
                  audioService.currentSong?.name ?? 'No name',
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  artistsDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white54,
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 28),
                        color: AppColors.white,
                        onPressed: () async {
                          final selected = await showDialog<List<LovResponse>>(
                            context: context,
                            builder: (context) => MultiSelectDialog(
                              fetchOptions: (searchTerm) => _playlistService
                                  .getLov(context, name: searchTerm),
                              selected: _selectedPlaylists,
                              onConfirm: (selected, context) async {
                                final success = await audioService
                                    .addToPlaylists(selected, context);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Added to playlists successfully',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: AppColors.greenAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error while adding to playlists',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: AppColors.redAccent,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                          if (selected != null) {
                            _handlePlaylistSelection(selected);
                          }
                        },
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.greenAccent : AppColors.white,
                        ),
                        onPressed: () {
                          audioService.toggleLikedStatus(context);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: double.infinity,
                        ),
                        child: Slider(
                          value: audioService.position.inSeconds.toDouble(),
                          min: 0,
                          max: audioService.duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            audioService.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(audioService.position),
                              style: const TextStyle(color: AppColors.white),
                            ),
                            Text(
                              _formatDuration(audioService.duration),
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous,
                            size: 36,
                            color: audioService.hasPreviousSong
                                ? AppColors.white
                                : AppColors.darkerGrey),
                        onPressed: audioService.hasPreviousSong
                            ? () async {
                                await _client.checkRefresh();
                                final token =
                                    await TokenStorage.getAccessToken();
                                audioService.playPreviousSong(context,
                                    headers: {
                                      'Authorization': 'Bearer $token'
                                    });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          playerState == AppPlayerState.playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 64,
                        ),
                        color: AppColors.white,
                        onPressed: audioService.togglePlayback,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          size: 36,
                          color: audioService.hasNextSong
                              ? AppColors.white
                              : AppColors.darkerGrey,
                        ),
                        onPressed: audioService.hasNextSong
                            ? () async {
                                await _client.checkRefresh();
                                final token =
                                    await TokenStorage.getAccessToken();
                                audioService.playNextSong(context, headers: {
                                  'Authorization': 'Bearer $token'
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePlaylistSelection(List<LovResponse> selected) {
    setState(() => _selectedPlaylists = selected);
  }

  Widget _buildSongImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 180,
          height: 180,
          color: Colors.grey[800],
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 180,
      height: 180,
      borderRadius: 8,
      iconData: Icons.music_note,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildMenuButton(SongResponse? song) {
    return PopupMenuButton<String>(
      elevation: 0,
      color: AppColors.background,
      surfaceTintColor: Colors.white,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, color: AppColors.white),
      onSelected: (value) async {
        if (value == 'details') {
          _handleDetails(song?.dateOfRelease, song?.viewCount, song?.likeCount,
              song?.genres);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'details', child: Text('Details')),
      ],
    );
  }

  Future<void> _handleDetails(String? dateOfRelease, int? viewCount,
      int? likeCount, List<GenreResponse>? genreList) async {
    _releaseDateController.text = dateOfRelease ?? 'Unknown';
    _viewCountController.text = viewCount?.toString() ?? '0';
    _likeCountController.text = likeCount?.toString() ?? '0';
    final genres = genreList?.map((g) => g.name).toList();
    final genresDisplay =
        genres != null && genres.isNotEmpty ? genres.join(', ') : "No genres";
    _genresController.text = genresDisplay;

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Details',
                style: TextStyle(fontSize: 18, color: AppColors.secondary)),
            IconButton(
              iconSize: 22,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
        content: IntrinsicHeight(
          child: Form(
            key: _detailsFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _releaseDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date of release',
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _viewCountController,
                  decoration: const InputDecoration(
                    labelText: 'Views',
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _likeCountController,
                  decoration: const InputDecoration(
                    labelText: 'Likes',
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genresController,
                  decoration: const InputDecoration(
                    labelText: 'Genres',
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}
