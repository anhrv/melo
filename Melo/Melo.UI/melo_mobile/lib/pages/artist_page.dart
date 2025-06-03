import 'package:flutter/material.dart';
import 'package:melo_mobile/models/artist_response.dart';
import 'package:melo_mobile/pages/album_search_page.dart';
import 'package:melo_mobile/pages/song_search_page.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class ArtistPage extends StatefulWidget {
  final int artistId;
  final int currentIndex;

  const ArtistPage(
      {super.key, required this.artistId, required this.currentIndex});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ArtistResponse? _artist;
  late ArtistService _artistService;
  bool _isLoading = true;
  bool _isLiked = false;
  String? _errorMessage;

  final _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _viewCountController = TextEditingController();
  final TextEditingController _likeCountController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _artistService = ArtistService(context);
    _fetchArtist();
  }

  Future<void> _fetchArtist() async {
    try {
      final artist = await _artistService.getById(widget.artistId, context);
      final isLiked = await _artistService.isLiked(widget.artistId, context);
      if (mounted) {
        setState(() {
          _artist = artist;
          _isLiked = isLiked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load artist: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "melo"),
      endDrawer: const UserDrawer(),
      bottomNavigationBar: BottomNavBar(currentIndex: widget.currentIndex),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_artist == null) {
      return const Center(child: Text('Artist not found'));
    }

    return DefaultTabController(
      length: 2,
      child: Stack(
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
                                  _artistService.unlike(
                                      widget.artistId, context);
                                }
                              : () {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                  });
                                  _artistService.like(widget.artistId, context);
                                },
                        ),
                        _buildMenuButton(),
                      ],
                    ),
                  ),
                ),
                _buildArtistImage(_artist?.imageUrl),
                _buildHeader(),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(color: AppColors.white54, width: 0.2),
                    ),
                  ),
                  child: const TabBar(
                    indicatorColor: Colors.transparent,
                    labelColor: AppColors.secondary,
                    unselectedLabelColor: AppColors.white70,
                    labelStyle: TextStyle(fontSize: 14),
                    tabs: [
                      Tab(text: 'Songs'),
                      Tab(text: 'Albums'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 470,
                  child: TabBarView(
                    children: [
                      SongSearchPage(
                        artistId: widget.artistId,
                        currentIndex: widget.currentIndex,
                      ),
                      AlbumSearchPage(
                        artistId: widget.artistId,
                        currentIndex: widget.currentIndex,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return Container(
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _artist?.name ?? "No name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtistImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          height: 120,
          color: AppColors.grey,
          child: const Icon(Icons.mic),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 120,
      height: 120,
      borderRadius: 8,
      iconData: Icons.mic,
    );
  }

  Future<void> _handleDetails() async {
    _viewCountController.text = _artist?.viewCount?.toString() ?? '0';
    _likeCountController.text = _artist?.likeCount?.toString() ?? '0';
    final genres = _artist?.genres.map((g) => g.name).toList();
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
