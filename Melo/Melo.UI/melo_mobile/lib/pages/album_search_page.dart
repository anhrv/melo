import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_mobile/models/album_response.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/pages/admin_album_add_page.dart';
import 'package:melo_mobile/pages/admin_album_edit_page.dart';
import 'package:melo_mobile/pages/album_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/album_service.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

class AlbumSearchPage extends StatefulWidget {
  final bool liked;

  const AlbumSearchPage({super.key, this.liked = false});

  @override
  State<AlbumSearchPage> createState() => _AlbumSearchPageState();
}

class _AlbumSearchPageState extends State<AlbumSearchPage> {
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  late Future<PagedResponse<AlbumResponse>?> _albumFuture;
  late AlbumService _albumService;

  bool _isFilterOpen = false;
  String? _selectedSortBy = 'createdAt';
  bool? _selectedSortOrder = false;

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];

  late ArtistService _artistService;
  List<LovResponse> _selectedArtists = [];

  static const _sortOptions = {
    'createdAt': 'Created date',
    'modifiedAt': 'Updated date',
    'viewCount': 'Views',
    'likeCount': 'Likes',
    'playtimeInSeconds': 'Playtime',
  };
  static const _orderOptions = {false: 'Descending', true: 'Ascending'};

  @override
  void initState() {
    super.initState();
    _albumService = AlbumService(context);
    _genreService = GenreService(context);
    _artistService = ArtistService(context);
    _albumFuture = _fetchAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResponse<AlbumResponse>?> _fetchAlbums() async {
    final name = _searchController.text.trim();
    return _albumService.get(
      context,
      widget.liked,
      page: _currentPage,
      name: name.isNotEmpty ? name : null,
      sortBy: _selectedSortBy,
      ascending: _selectedSortOrder,
      genreIds: _selectedGenres.isNotEmpty
          ? _selectedGenres.map((g) => g.id).toList()
          : null,
      artistIds: _selectedArtists.isNotEmpty
          ? _selectedArtists.map((a) => a.id).toList()
          : null,
    );
  }

  void _performSearch() {
    setState(() {
      _currentPage = 1;
      _albumFuture = _fetchAlbums();
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _albumFuture = _fetchAlbums();
    });
  }

  void _handleGenreSelection(List<LovResponse> selected) {
    setState(() => _selectedGenres = selected);
  }

  void _handleArtistSelection(List<LovResponse> selected) {
    setState(() => _selectedArtists = selected);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;

    return Scaffold(
      appBar: isAdmin ? const CustomAppBar(title: "Albums") : null,
      drawer: isAdmin ? const AdminAppDrawer() : null,
      endDrawer: const UserDrawer(),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isFilterOpen) {
                setState(() => _isFilterOpen = false);
              }
            },
          ),
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
                      const SizedBox(
                        height: 4,
                      ),
                      _buildSearchBar(isAdmin),
                      FutureBuilder<PagedResponse<AlbumResponse>?>(
                        future: _albumFuture,
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
                                  const Center(child: Text('No albums found')),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 8,
                                    left: 16,
                                  ),
                                  child: Text(
                                    '${data.items} of ${data.totalItems}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              _buildAlbumList(data.data, isAdmin),
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
          if (_isFilterOpen)
            ModalBarrier(
              dismissible: true,
              color: Colors.black54,
              onDismiss: () => setState(() => _isFilterOpen = false),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isFilterOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _buildFilterPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isAdmin) {
    return Container(
      height: kToolbarHeight * 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.filter_alt),
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isFilterOpen = !_isFilterOpen;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 60,
            child: SizedBox(
              height: kToolbarHeight * 0.9,
              child: TextField(
                controller: _searchController,
                cursorColor: AppColors.primary,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _performSearch,
                    padding: EdgeInsets.zero,
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isAdmin)
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.add),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminAlbumAddPage()),
                  ).then((_) {
                    setState(() {
                      _currentPage = 1;
                      _albumFuture = _fetchAlbums();
                    });
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumList(List<AlbumResponse> albums, bool isAdmin) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final artists = album.artists.map((a) => a.name);
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
              leading: _buildAlbumImage(album.imageUrl),
              title: Text(
                album.name ?? 'No name',
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
                      Text(
                        album.playtime ?? '0:00',
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
                            album.viewCount?.toString() ?? '0',
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
                            album.likeCount?.toString() ?? '0',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${album.songCount?.toString() ?? "0"} ${album.songCount == 1 ? "song" : "songs"}",
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: isAdmin
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: PopupMenuButton<String>(
                        elevation: 0,
                        color: AppColors.backgroundLighter2,
                        surfaceTintColor: Colors.white,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminAlbumEditPage(
                                  albumId: album.id,
                                  initialEditMode: true,
                                ),
                              ),
                            ).then((_) {
                              setState(() {
                                _albumFuture = _fetchAlbums();
                              });
                            });
                          } else if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 0.0),
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
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this album? This action is permanent.',
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
                                  await _albumService.delete(album.id, context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Album deleted successfully",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: AppColors.greenAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                setState(() {
                                  _albumFuture = _fetchAlbums();
                                });
                              }
                            }
                          }
                        },
                      ),
                    )
                  : widget.liked
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: PopupMenuButton<String>(
                            elevation: 0,
                            color: AppColors.backgroundLighter2,
                            surfaceTintColor: Colors.white,
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'unlike',
                                child: Text('Unlike'),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'unlike') {
                                if (mounted) {
                                  final success = await _albumService.unlike(
                                      album.id, context);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Album unliked",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: AppColors.greenAccent,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    setState(() {
                                      _albumFuture = _fetchAlbums();
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        )
                      : null,
              contentPadding: EdgeInsets.only(
                left: 16,
                right: isAdmin || widget.liked ? 0 : 28,
                top: 8,
                bottom: 8,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAdmin
                        ? AdminAlbumEditPage(albumId: album.id)
                        : AlbumPage(albumId: album.id, currentIndex: 0),
                  ),
                ).then((_) {
                  setState(() {
                    _albumFuture = _fetchAlbums();
                  });
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          color: AppColors.grey,
          child: const Icon(Icons.album),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 60,
      height: 60,
      borderRadius: 8,
      iconData: Icons.album,
    );
  }

  Widget _buildPagination(PagedResponse<AlbumResponse> data) {
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

  Widget _buildFilterPanel() {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(width: 1),
    );

    return Container(
      width: 280,
      color: AppColors.white,
      child: Material(
        elevation: 16,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _isFilterOpen = false),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Text(
                        'Artists',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedArtists.map((artist) {
                            return Chip(
                              label: Text(artist.name),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              deleteIconColor: AppColors.grey,
                              onDeleted: () => setState(
                                  () => _selectedArtists.remove(artist)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.grey,
                                  width: 0.5,
                                ),
                              ),
                              backgroundColor: AppColors.background,
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "Select artists",
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 14,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final selected =
                                          await showDialog<List<LovResponse>>(
                                        context: context,
                                        builder: (context) => MultiSelectDialog(
                                          fetchOptions: (searchTerm) =>
                                              _artistService.getLov(context,
                                                  name: searchTerm),
                                          selected: _selectedArtists,
                                        ),
                                      );
                                      if (selected != null) {
                                        _handleArtistSelection(selected);
                                      }
                                    },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Text(
                        'Genres',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedGenres.map((genre) {
                            return Chip(
                              label: Text(genre.name),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              deleteIconColor: AppColors.grey,
                              onDeleted: () =>
                                  setState(() => _selectedGenres.remove(genre)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.grey,
                                  width: 0.5,
                                ),
                              ),
                              backgroundColor: AppColors.background,
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "Select genres",
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 14,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final selected =
                                          await showDialog<List<LovResponse>>(
                                        context: context,
                                        builder: (context) => MultiSelectDialog(
                                          fetchOptions: (searchTerm) =>
                                              _genreService.getLov(context,
                                                  name: searchTerm),
                                          selected: _selectedGenres,
                                        ),
                                      );
                                      if (selected != null) {
                                        _handleGenreSelection(selected);
                                      }
                                    },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  dropdownColor: AppColors.backgroundLighter2,
                  elevation: 0,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1,
                        color: AppColors.white54,
                      ),
                    ),
                    focusedBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    filled: true,
                    isDense: true,
                  ),
                  value: _selectedSortBy,
                  onChanged: (value) => setState(() => _selectedSortBy = value),
                  items: _sortOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Sort order',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  dropdownColor: AppColors.backgroundLighter2,
                  elevation: 0,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1,
                        color: AppColors.white54,
                      ),
                    ),
                    focusedBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    filled: true,
                    isDense: true,
                  ),
                  value: _selectedSortOrder,
                  onChanged: (value) =>
                      setState(() => _selectedSortOrder = value),
                  items: _orderOptions.entries.map((entry) {
                    return DropdownMenuItem<bool>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 38),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _performSearch();
                      setState(() => _isFilterOpen = false);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
