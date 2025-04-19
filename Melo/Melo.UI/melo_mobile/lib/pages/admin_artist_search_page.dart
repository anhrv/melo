import 'dart:math';

import 'package:flutter/material.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/models/artist_response.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/pages/admin_artist_add_page.dart';
import 'package:melo_mobile/pages/admin_artist_edit_page.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminArtistSearchPage extends StatefulWidget {
  const AdminArtistSearchPage({super.key});

  @override
  State<AdminArtistSearchPage> createState() => _AdminArtistSearchPageState();
}

class _AdminArtistSearchPageState extends State<AdminArtistSearchPage> {
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  late Future<PagedResponse<ArtistResponse>?> _artistFuture;
  late ArtistService _artistService;

  bool _isFilterOpen = false;
  String? _selectedSortBy = 'createdAt';
  bool? _selectedSortOrder = false;

  late GenreService _genreService;
  List<int> _selectedGenreIds = [];
  late Future<List<LovResponse>> _genresFuture;

  static const _sortOptions = {
    'createdAt': 'Created date',
    'modifiedAt': 'Updated date',
    'viewCount': 'Views',
    'likeCount': 'Likes'
  };
  static const _orderOptions = {true: 'Ascending', false: 'Descending'};

  @override
  void initState() {
    super.initState();
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
    _genresFuture = _genreService.getLov(context);
    _artistFuture = _fetchArtists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResponse<ArtistResponse>?> _fetchArtists() async {
    final name = _searchController.text.trim();
    return _artistService.get(
      context,
      page: _currentPage,
      name: name.isNotEmpty ? name : null,
      sortBy: _selectedSortBy,
      ascending: _selectedSortOrder,
      genreIds: _selectedGenreIds.isNotEmpty ? _selectedGenreIds : null,
    );
  }

  void _performSearch() {
    setState(() {
      _currentPage = 1;
      _artistFuture = _fetchArtists();
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _artistFuture = _fetchArtists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Artists"),
      drawer: const AdminAppDrawer(),
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
                      _buildSearchBar(),
                      FutureBuilder<PagedResponse<ArtistResponse>?>(
                        future: _artistFuture,
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
                                  const Center(child: Text('No artists found')),
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
                              _buildArtistList(data.data),
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

  Widget _buildSearchBar() {
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
                  hintText: 'Search artists',
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
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
                      builder: (context) => const AdminArtistAddPage()),
                ).then((_) {
                  setState(() {
                    _currentPage = 1;
                    _artistFuture = _fetchArtists();
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistList(List<ArtistResponse> artists) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
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
              leading: _buildArtistImage(artist.imageUrl),
              title: Text(artist.name ?? 'No name'),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye,
                    color: AppColors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    artist.viewCount?.toString() ?? '0',
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
                    artist.likeCount?.toString() ?? '0',
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PopupMenuButton<String>(
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
                          builder: (context) => AdminArtistEditPage(
                            artistId: artist.id,
                            initialEditMode: true,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _artistFuture = _fetchArtists();
                        });
                      });
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text(
                            'Delete artist',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.redAccent,
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this artist? This action is permanent.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.white,
                            ),
                          ),
                          backgroundColor: AppColors.background,
                          surfaceTintColor: Colors.transparent,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                  )),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
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
                            await _artistService.delete(artist.id, context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Artist deleted successfully",
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
                            _artistFuture = _fetchArtists();
                          });
                        }
                      }
                    }
                  },
                ),
              ),
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 0,
                top: 8,
                bottom: 8,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminArtistEditPage(artistId: artist.id),
                  ),
                ).then((_) {
                  setState(() {
                    _artistFuture = _fetchArtists();
                  });
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtistImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          color: AppColors.grey,
          child: const Icon(Icons.mic),
        ),
      );
    }

    //todo: figure out
    final processedUrl = imageUrl
        .replaceFirst('localhost:7236', ApiConstants.fileServer)
        .replaceFirst('https', 'http');

    return CustomImage(
      imageUrl: processedUrl,
      width: 50,
      height: 50,
      borderRadius: 8,
      iconData: Icons.mic,
    );
  }

  Widget _buildPagination(PagedResponse<ArtistResponse> data) {
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
      borderRadius: BorderRadius.all(Radius.circular(30)),
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
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _isFilterOpen = false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Genres',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<LovResponse>>(
                  future: _genresFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No genres available');
                    } else {
                      final genres = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 0.0,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 8,
                              runSpacing: -4,
                              children: _selectedGenreIds.map((id) {
                                final genre = genres.firstWhere(
                                  (g) => g.id == id,
                                  orElse: () =>
                                      LovResponse(id: id, name: 'Unknown'),
                                );
                                return Chip(
                                  label: Text(genre.name),
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(
                                      color: AppColors.grey,
                                      width: 0.5,
                                    ),
                                  ),
                                  backgroundColor: AppColors.background,
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  deleteIconColor: AppColors.grey,
                                  onDeleted: () => setState(
                                    () => _selectedGenreIds.remove(id),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final selected = await showDialog<List<int>>(
                                context: context,
                                builder: (context) => MultiSelectDialog(
                                  options: genres,
                                  selected: _selectedGenreIds,
                                ),
                              );
                              if (selected != null) {
                                setState(() => _selectedGenreIds = selected);
                              }
                            },
                            child: const Text(
                              'Select genres',
                              style: TextStyle(
                                  color: AppColors.secondary, fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
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
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Sort order',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
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
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
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
