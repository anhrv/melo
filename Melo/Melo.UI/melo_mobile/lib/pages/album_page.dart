import 'package:flutter/material.dart';
import 'package:melo_mobile/models/album_response.dart';
import 'package:melo_mobile/models/album_song_response.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/services/album_service.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/app_shell.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

class AlbumPage extends StatefulWidget {
  final int albumId;
  final int currentIndex;

  const AlbumPage(
      {super.key, required this.albumId, required this.currentIndex});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  AlbumResponse? _album;
  late AlbumService _albumService;
  late AudioPlayerService _audioPlayer;
  bool _isLoading = true;
  bool _isLiked = false;
  String? _errorMessage;

  final _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _viewCountController = TextEditingController();
  final TextEditingController _likeCountController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = context.read<AudioPlayerService>();
    _audioPlayer.addListener(() {
      if (mounted) setState(() {});
    });

    _albumService = AlbumService(context);
    _fetchAlbum();
  }

  @override
  void dispose() {
    _audioPlayer.removeListener(() {});
    super.dispose();
  }

  Future<void> _fetchAlbum() async {
    try {
      final album = await _albumService.getById(widget.albumId, context);
      final isLiked = await _albumService.isLiked(widget.albumId, context);
      if (mounted) {
        setState(() {
          _album = album;
          _isLiked = isLiked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load album: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Scaffold(
        appBar: const CustomAppBar(title: "melo"),
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        bottomNavigationBar: BottomNavBar(currentIndex: widget.currentIndex),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_album == null) {
      return const Center(child: Text('Album not found'));
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 4.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked
                              ? AppColors.greenAccent
                              : AppColors.white,
                        ),
                        onPressed: _isLiked
                            ? () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                                _albumService.unlike(widget.albumId, context);
                              }
                            : () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                                _albumService.like(widget.albumId, context);
                              },
                      ),
                      _buildMenuButton(),
                    ],
                  ),
                ),
              ),
              _buildAlbumImage(_album?.imageUrl),
              _buildHeader(),
              _buildSongList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      elevation: 0,
      color: AppColors.backgroundLighter2,
      surfaceTintColor: Colors.white,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, color: AppColors.white),
      onSelected: (value) async {
        if (value == 'details') {
          _handleDetails();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'details', child: Text('Details')),
      ],
    );
  }

  Widget _buildHeader() {
    final artists = _album?.artists.map((a) => a.name).toList();
    final artistsDisplay = artists != null && artists.isNotEmpty
        ? artists.join(', ')
        : "No artists";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.4, color: AppColors.grey),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _album?.name ?? "No name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                artistsDisplay,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_album?.songCount?.toString() ?? "0"} ${_album?.songCount == 1 ? "song" : "songs"}",
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _album?.playtime ?? '0:00',
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _album?.songs ?? [];
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No songs in this album',
            style: TextStyle(color: AppColors.white54)),
      );
    }

    return Column(
      children: List.generate(songs.length, (index) {
        final song = songs[index];
        final artists = song.artists.map((a) => a.name).toList();
        final artistsDisplay =
            artists.isNotEmpty ? artists.join(', ') : "No artists";

        return Column(
          children: [
            ListTile(
              tileColor: _isCurrentSong(song) ? AppColors.secondaryTint : null,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _buildSongImage(song.imageUrl),
                  ),
                ],
              ),
              title: Text(
                song.name ?? "No name",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          artistsDisplay,
                          style: const TextStyle(
                            color: AppColors.white54,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        song.playtime ?? '0:00',
                        style: const TextStyle(
                          color: AppColors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          color: AppColors.grey, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        song.viewCount?.toString() ?? '0',
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_up,
                          color: AppColors.grey, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        song.likeCount?.toString() ?? '0',
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.only(
                  left: 0, right: 16, top: 12, bottom: 12),
              onTap: () async {
                if (song.audioUrl == null) {
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

                if (currentSong?.audioUrl == song.audioUrl) {
                  _audioPlayer.togglePlayback();
                } else {
                  _audioPlayer.playSong(
                    song,
                    context,
                    headers: {'Authorization': 'Bearer $token'},
                  );
                }
              },
            ),
            if (index < songs.length - 1)
              Divider(
                height: 1,
                thickness: 0.2,
                color: AppColors.white54,
              ),
          ],
        );
      }),
    );
  }

  bool _isCurrentSong(AlbumSongResponse song) {
    return _audioPlayer.currentSong?.audioUrl != null &&
        song.audioUrl != null &&
        _audioPlayer.currentSong?.audioUrl == song.audioUrl;
  }

  Widget _buildAlbumImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          height: 120,
          color: AppColors.grey,
          child: const Icon(Icons.album),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 120,
      height: 120,
      borderRadius: 8,
      iconData: Icons.album,
    );
  }

  Widget _buildSongImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: AppColors.grey,
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 48,
      height: 48,
      borderRadius: 8,
      iconData: Icons.music_note,
    );
  }

  Future<void> _handleDetails() async {
    _releaseDateController.text = _album?.dateOfRelease ?? 'Unknown';
    _viewCountController.text = _album?.viewCount?.toString() ?? '0';
    _likeCountController.text = _album?.likeCount?.toString() ?? '0';
    final genres = _album?.genres.map((g) => g.name).toList();
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
