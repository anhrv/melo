import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:provider/provider.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({super.key});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context, listen: true);
    final playerState = audioService.playerState;

    final artists = audioService.currentSong?.artists.map((a) => a.name);
    final artistsDisplay = artists?.join(', ') ?? "No artist";

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
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.white),
                      onPressed: () {
                        // TODO: Implement menu
                      },
                    ),
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
                        onPressed: () {},
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 28),
                        color: AppColors.white,
                        onPressed: () {},
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
                        icon: const Icon(Icons.skip_previous, size: 36),
                        color: AppColors.white,
                        onPressed: () {},
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
                        icon: const Icon(Icons.skip_next, size: 36),
                        color: AppColors.white,
                        onPressed: () {},
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
}
