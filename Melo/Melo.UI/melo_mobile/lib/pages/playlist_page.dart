import 'dart:math';

import 'package:flutter/material.dart';
import 'package:melo_mobile/models/playlist_response.dart';
import 'package:melo_mobile/models/playlist_song_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/services/playlist_service.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/app_shell.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  final PlaylistResponse playlist;

  PlaylistPage({super.key, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  int _currentPage = 1;
  int _songCount = 0;
  String _name = "";
  late Future<PagedResponse<PlaylistSongResponse>?> _songFuture;
  late PlaylistService _playlistService;
  late AudioPlayerService _audioPlayer;

  final _editFormKey = GlobalKey<FormState>();
  final TextEditingController _editNameController = TextEditingController();

  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer = context.read<AudioPlayerService>();
    _audioPlayer.addListener(() {
      if (mounted) setState(() {});
    });
    _playlistService = PlaylistService(context);
    _songFuture = _fetchSongs(25);
    _songCount = widget.playlist.songCount ?? 0;
    _name = widget.playlist.name ?? "No name";
  }

  @override
  void dispose() {
    _audioPlayer.removeListener(() {});
    super.dispose();
  }

  Future<PagedResponse<PlaylistSongResponse>?> _fetchSongs(int pagesize) async {
    return _playlistService.getSongs(
      context,
      playlistId: widget.playlist.id,
      page: _currentPage,
      pagesize: pagesize,
    );
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _songFuture = _fetchSongs(25);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Scaffold(
        appBar: const CustomAppBar(title: "melo"),
        drawer: null,
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.4,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_songCount.toString()} ${_songCount == 1 ? "song" : "songs"}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.white54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 16,
                                child: PopupMenuButton<String>(
                                  elevation: 0,
                                  color: AppColors.backgroundLighter2,
                                  surfaceTintColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _editFormKey.currentState?.reset();
                                      setState(() {
                                        _fieldErrors = {};
                                        _editNameController.text =
                                            widget.playlist.name ?? "";
                                      });
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) =>
                                                AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 0.0),
                                                    child: Text(
                                                      'Edit playlist',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            AppColors.secondary,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    iconSize: 22,
                                                    icon:
                                                        const Icon(Icons.close),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                  ),
                                                ],
                                              ),
                                              content: Form(
                                                key: _editFormKey,
                                                child: TextFormField(
                                                  controller:
                                                      _editNameController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Name',
                                                    errorText:
                                                        _fieldErrors['Name'],
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Name is required';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppColors.background,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: (_editNameController
                                                              .text
                                                              .isNotEmpty &&
                                                          _editNameController
                                                                  .text !=
                                                              widget.playlist
                                                                  .name)
                                                      ? () async {
                                                          _fieldErrors = {};
                                                          if (!_editFormKey
                                                              .currentState!
                                                              .validate()) {
                                                            setState(() {});
                                                            return;
                                                          }
                                                          FocusScope.of(context)
                                                              .unfocus();

                                                          final updatedPlaylist =
                                                              await _playlistService
                                                                  .update(
                                                            widget.playlist.id,
                                                            _editNameController
                                                                .text,
                                                            context,
                                                            (errors) {
                                                              setState(() =>
                                                                  _fieldErrors =
                                                                      errors);
                                                            },
                                                          );
                                                          if (updatedPlaylist !=
                                                              null) {
                                                            Navigator.pop(
                                                                context, true);
                                                          }
                                                        }
                                                      : null,
                                                  child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: (_editNameController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              _editNameController
                                                                      .text !=
                                                                  widget
                                                                      .playlist
                                                                      .name)
                                                          ? AppColors.white
                                                          : AppColors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      if (confirmed == true && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Playlist updated successfully",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor:
                                                AppColors.greenAccent,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        setState(() {
                                          _name = _editNameController.text;
                                        });
                                      }
                                    } else if (value == 'delete') {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 0.0),
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppColors.redAccent,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                iconSize: 22,
                                                icon: const Icon(Icons.close),
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                              ),
                                            ],
                                          ),
                                          content: const Text(
                                            'Are you sure you want to delete this playlist? This action is permanent.',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.white,
                                            ),
                                          ),
                                          backgroundColor: AppColors.background,
                                          surfaceTintColor: Colors.transparent,
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('No',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.white,
                                                  )),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Yes',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.white,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true && mounted) {
                                        final success =
                                            await _playlistService.delete(
                                                widget.playlist.id, context);
                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Playlist deleted successfully",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppColors.greenAccent,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    } else if (value == 'reorder') {
                                      _showReorderDialog();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                    if (_songCount > 1)
                                      const PopupMenuItem(
                                        value: 'reorder',
                                        child: Text('Reorder'),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<PagedResponse<PlaylistSongResponse>?>(
                          future: _songFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height:
                                    constraints.maxHeight - kToolbarHeight * 2,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            if (snapshot.hasError) {
                              return SizedBox(
                                height:
                                    constraints.maxHeight - kToolbarHeight * 2,
                                child: Center(
                                    child: Text('Error: ${snapshot.error}')),
                              );
                            }
                            final data = snapshot.data;
                            if (data == null || data.data.isEmpty) {
                              return SizedBox(
                                height:
                                    constraints.maxHeight - kToolbarHeight * 2,
                                child:
                                    const Center(child: Text('No songs found')),
                              );
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSongList(data.data),
                                _buildPagination(data),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReorderDialog() async {
    List<PlaylistSongResponse> workingList = [];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return FutureBuilder<PagedResponse<PlaylistSongResponse>?>(
          future: _playlistService.getSongs(
            context,
            playlistId: widget.playlist.id,
            page: 1,
            pagesize: 1000,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                content: Text('Error: ${snapshot.error}'),
              );
            }

            final songs = snapshot.data!.data;
            workingList = List.from(songs);

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: AppColors.background,
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reorder songs',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.secondary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            itemCount: workingList.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) newIndex--;
                                final item = workingList.removeAt(oldIndex);
                                workingList.insert(newIndex, item);
                              });
                            },
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final song = workingList[index];
                              return Container(
                                key: ValueKey(song.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const MouseRegion(
                                          cursor: SystemMouseCursors.grab,
                                          child: Icon(
                                            Icons.drag_handle,
                                            size: 20,
                                            color: AppColors.white54,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          color: AppColors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          song.name ?? 'No name',
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                ),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: () async {
                                  final success =
                                      await _playlistService.reorderSongs(
                                    context,
                                    playlistId: widget.playlist.id,
                                    songIds:
                                        workingList.map((s) => s.id).toList(),
                                  );
                                  Navigator.pop(context, success);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Playlist updated successfully",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
      final newData = await _fetchSongs(25);
      if (mounted) {
        setState(() {
          _songFuture = Future.value(newData);
        });
      }
    }
  }

  Widget _buildSongList(List<PlaylistSongResponse> songs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final artists = song.artists.map((a) => a.name);
        final artistsDisplay = artists.join(', ');

        return Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.grey,
                width: 0.1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.1),
            child: ListTile(
              tileColor: _isCurrentSong(song) ? AppColors.secondaryTint : null,
              leading: _buildSongImage(song.imageUrl),
              title: Text(
                song.name ?? "No name",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          artistsDisplay != "" ? artistsDisplay : "No artists",
                          style: const TextStyle(
                            color: AppColors.white54,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        song.playtime ?? '0:00',
                        style: const TextStyle(
                          color: AppColors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: AppColors.grey,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            song.viewCount?.toString() ?? '0',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.thumb_up,
                            color: AppColors.grey,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            song.likeCount?.toString() ?? '0',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PopupMenuButton<String>(
                  elevation: 0,
                  color: AppColors.backgroundLighter2,
                  surfaceTintColor: Colors.white,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'remove') {
                      if (mounted) {
                        final success = await _playlistService.removeSong(
                          context,
                          playlistId: widget.playlist.id,
                          songIds: [song.id],
                        );
                        if (success) {
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Song removed from playlist",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: AppColors.greenAccent,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            _songCount--;
                            _songFuture = _fetchSongs(25);
                          });
                        }
                      }
                    }
                  },
                ),
              ),
              contentPadding: EdgeInsets.only(
                left: 16,
                right: 0,
                top: 8,
                bottom: 8,
              ),
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
          ),
        );
      },
    );
  }

  bool _isCurrentSong(PlaylistSongResponse song) {
    return _audioPlayer.currentSong?.audioUrl != null &&
        song.audioUrl != null &&
        _audioPlayer.currentSong?.audioUrl == song.audioUrl;
  }

  Widget _buildSongImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          color: AppColors.grey,
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 60,
      height: 60,
      borderRadius: 8,
      iconData: Icons.music_note,
    );
  }

  Widget _buildPagination(PagedResponse<PlaylistSongResponse> data) {
    const int maxVisiblePages = 3;
    final int current = data.page;
    final int total = data.totalPages;

    List<int?> pages = [];
    if (total <= maxVisiblePages + 2) {
      pages = List.generate(total, (i) => i + 1);
    } else {
      int start = current - (maxVisiblePages ~/ 2);
      int end = current + (maxVisiblePages ~/ 2);

      if (start < 1) {
        start = 1;
        end = maxVisiblePages;
      }
      if (end > total) {
        end = total;
        start = max(1, end - maxVisiblePages + 1);
      }

      if (start > 1) pages.add(1);
      if (start > 2) pages.add(null);

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }

      if (end < total - 1) pages.add(null);
      if (end < total) pages.add(total);
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                data.prevPage != null ? () => _loadPage(data.prevPage!) : null,
          ),
          const SizedBox(width: 6),
          Row(
            children: pages.map((page) {
              if (page == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text('...', style: TextStyle(color: AppColors.grey)),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => _loadPage(page),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: page == current
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: page == current
                            ? Colors.white
                            : AppColors.secondary,
                        fontWeight: page == current
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                data.nextPage != null ? () => _loadPage(data.nextPage!) : null,
          ),
        ],
      ),
    );
  }
}
