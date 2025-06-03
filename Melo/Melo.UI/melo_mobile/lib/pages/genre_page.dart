import 'package:flutter/material.dart';
import 'package:melo_mobile/models/genre_response.dart';
import 'package:melo_mobile/pages/album_search_page.dart';
import 'package:melo_mobile/pages/artist_search_page.dart';
import 'package:melo_mobile/pages/song_search_page.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class GenrePage extends StatefulWidget {
  final int genreId;
  final int currentIndex;

  const GenrePage(
      {super.key, required this.genreId, required this.currentIndex});

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  GenreResponse? _genre;
  late GenreService _genreService;
  bool _isLoading = true;
  String? _errorMessage;

  final _detailsFormKey = GlobalKey<FormState>();
  final TextEditingController _viewCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _genreService = GenreService(context);
    _fetchGenre();
  }

  Future<void> _fetchGenre() async {
    try {
      final genre = await _genreService.getById(widget.genreId, context);
      if (mounted) {
        setState(() {
          _genre = genre;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load genre: ${e.toString()}';
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

    if (_genre == null) {
      return const Center(child: Text('Genre not found'));
    }

    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0, right: 4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildMenuButton(),
              ),
            ),
            _buildGenreImage(_genre?.imageUrl),
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
                  Tab(text: 'Artists'),
                ],
              ),
            ),
            SizedBox(
              height: 470,
              child: TabBarView(
                children: [
                  SongSearchPage(
                    genreId: widget.genreId,
                    currentIndex: widget.currentIndex,
                  ),
                  AlbumSearchPage(
                    genreId: widget.genreId,
                    currentIndex: widget.currentIndex,
                  ),
                  ArtistSearchPage(
                    genreId: widget.genreId,
                    currentIndex: widget.currentIndex,
                  ),
                ],
              ),
            ),
          ],
        ),
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
                _genre?.name ?? "No name",
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

  Widget _buildGenreImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          height: 120,
          color: AppColors.grey,
          child: const Icon(Icons.type_specimen),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 120,
      height: 120,
      borderRadius: 8,
      iconData: Icons.type_specimen,
    );
  }

  Future<void> _handleDetails() async {
    _viewCountController.text = _genre?.viewCount?.toString() ?? '0';

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
