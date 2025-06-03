import 'dart:math';

import 'package:flutter/material.dart';
import 'package:melo_mobile/models/genre_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/pages/admin_genre_add_page.dart';
import 'package:melo_mobile/pages/admin_genre_edit_page.dart';
import 'package:melo_mobile/pages/genre_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

class GenreSearchPage extends StatefulWidget {
  final int? currentIndex;
  const GenreSearchPage({super.key, this.currentIndex});

  @override
  State<GenreSearchPage> createState() => _GenreSearchPageState();
}

class _GenreSearchPageState extends State<GenreSearchPage> {
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  late Future<PagedResponse<GenreResponse>?> _genreFuture;
  late GenreService _genreService;

  bool _isFilterOpen = false;
  String? _selectedSortBy = 'createdAt';
  bool? _selectedSortOrder = false;

  static const _sortOptions = {
    'createdAt': 'Created date',
    'modifiedAt': 'Updated date',
    'viewCount': 'Views'
  };
  static const _orderOptions = {false: 'Descending', true: 'Ascending'};

  @override
  void initState() {
    super.initState();
    _genreService = GenreService(context);
    _genreFuture = _fetchGenres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResponse<GenreResponse>?> _fetchGenres() async {
    final name = _searchController.text.trim();
    return _genreService.get(
      context,
      page: _currentPage,
      name: name.isNotEmpty ? name : null,
      sortBy: _selectedSortBy,
      ascending: _selectedSortOrder,
    );
  }

  void _performSearch() {
    setState(() {
      _currentPage = 1;
      _genreFuture = _fetchGenres();
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _genreFuture = _fetchGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;

    return Scaffold(
      appBar: isAdmin ? const CustomAppBar(title: "Genres") : null,
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
                      FutureBuilder<PagedResponse<GenreResponse>?>(
                        future: _genreFuture,
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
                                  const Center(child: Text('No genres found')),
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
                              _buildGenreList(data.data, isAdmin),
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
                        builder: (context) => const AdminGenreAddPage()),
                  ).then((_) {
                    setState(() {
                      _currentPage = 1;
                      _genreFuture = _fetchGenres();
                    });
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenreList(List<GenreResponse> genres, bool isAdmin) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
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
              leading: _buildGenreImage(genre.imageUrl),
              title: Text(
                genre.name ?? 'No name',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye,
                    color: AppColors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    genre.viewCount?.toString() ?? '0',
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
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
                                builder: (context) => AdminGenreEditPage(
                                  genreId: genre.id,
                                  initialEditMode: true,
                                ),
                              ),
                            ).then((_) {
                              setState(() {
                                _genreFuture = _fetchGenres();
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
                                  'Are you sure you want to delete this genre? This action is permanent.',
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
                                  await _genreService.delete(genre.id, context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Genre deleted successfully",
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
                                  _genreFuture = _fetchGenres();
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
                right: isAdmin ? 0 : 28,
                top: 8,
                bottom: 8,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAdmin
                        ? AdminGenreEditPage(genreId: genre.id)
                        : GenrePage(
                            genreId: genre.id,
                            currentIndex: widget.currentIndex ?? 0),
                  ),
                ).then((_) {
                  setState(() {
                    _genreFuture = _fetchGenres();
                  });
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          color: AppColors.grey,
          child: const Icon(Icons.type_specimen),
        ),
      );
    }

    return CustomImage(
      imageUrl: imageUrl,
      width: 50,
      height: 50,
      borderRadius: 8,
      iconData: Icons.type_specimen,
    );
  }

  Widget _buildPagination(PagedResponse<GenreResponse> data) {
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
                      padding: EdgeInsets.only(
                        left: 4.0,
                      ),
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
                const SizedBox(height: 40),
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
