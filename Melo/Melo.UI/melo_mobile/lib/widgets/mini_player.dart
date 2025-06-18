import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  Widget _buildSongImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          color: Colors.grey[800],
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 40,
      height: 40,
      borderRadius: 4,
      iconData: Icons.music_note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = context.watch<AudioPlayerService>();
    final playerState = audioService.playerState;

    final artists = audioService.currentSong?.artists.map((a) => a.name);
    final artistsDisplay = artists?.join(', ') ?? "No artist";

    return Column(
      children: [
        LinearProgressIndicator(
          value: audioService.duration.inSeconds > 0
              ? (audioService.position.inSeconds /
                      audioService.duration.inSeconds)
                  .clamp(0.0, 1.0)
              : 0,
          minHeight: 2,
          backgroundColor: Colors.grey[700],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
        Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
          ),
          child: Row(
            children: [
              _buildSongImage(audioService.currentSong?.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      audioService.currentSong?.name ?? 'No name',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      artistsDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              playerState == AppPlayerState.buffering
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        playerState == AppPlayerState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: AppColors.white,
                        size: 28,
                      ),
                      onPressed: audioService.togglePlayback,
                    ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: audioService.closePlayer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
