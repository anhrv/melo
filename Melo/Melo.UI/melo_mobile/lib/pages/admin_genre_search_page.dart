import 'dart:math';

import 'package:flutter/material.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/models/genre_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminGenreSearchPage extends StatefulWidget {
  const AdminGenreSearchPage({super.key});

  @override
  State<AdminGenreSearchPage> createState() => _AdminGenreSearchPageState();
}

class _AdminGenreSearchPageState extends State<AdminGenreSearchPage> {
  int _currentPage = 1;
  late Future<PagedResponse<GenreResponse>?> _genreFuture;
  late GenreService _genreService;

  @override
  void initState() {
    super.initState();
    _genreService = GenreService(context);
    _genreFuture = _fetchGenres();
  }

  Future<PagedResponse<GenreResponse>?> _fetchGenres() async {
    return _genreService.get(_currentPage, context);
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _genreFuture = _fetchGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Genres"),
      drawer: const AdminAppDrawer(),
      endDrawer: const UserDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSearchBar(),
                  FutureBuilder<PagedResponse<GenreResponse>?>(
                    future: _genreFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: constraints.maxHeight - kToolbarHeight * 2,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return SizedBox(
                          height: constraints.maxHeight - kToolbarHeight * 2,
                          child:
                              Center(child: Text('Error: ${snapshot.error}')),
                        );
                      }
                      final data = snapshot.data;
                      if (data == null || data.data.isEmpty) {
                        return SizedBox(
                          height: constraints.maxHeight - kToolbarHeight * 2,
                          child: const Center(child: Text('No genres found')),
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildGenreList(data.data),
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
                //todo: filter
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 60,
            child: SizedBox(
              height: kToolbarHeight * 0.9,
              child: TextField(
                cursorColor: AppColors.primary,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search genres',
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
                ),
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
                //todo: handle add
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreList(List<GenreResponse> genres) {
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
              title: Text(genre.name ?? 'No name'),
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
                  onSelected: (value) {
                    //todo: handle edit and delete
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
                //todo: handle genre view
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

    //todo: figure out
    final processedUrl = imageUrl
        .replaceFirst('localhost:7236', ApiConstants.fileServer)
        .replaceFirst('s', '');

    return CustomImage(
      imageUrl: processedUrl,
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
}
