import 'package:flutter/material.dart';
import 'package:melo_desktop/pages/admin_analytics_page.dart';
import 'package:melo_desktop/pages/admin_home_page.dart';
import 'package:melo_desktop/pages/admin_recommender_page.dart';
import 'package:melo_desktop/pages/admin_user_search_page.dart';
import 'package:melo_desktop/pages/album_search_page.dart';
import 'package:melo_desktop/pages/artist_search_page.dart';
import 'package:melo_desktop/pages/genre_search_page.dart';
import 'package:melo_desktop/pages/song_search_page.dart';
import 'package:melo_desktop/themes/app_colors.dart';

class AdminSideMenuScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;

  const AdminSideMenuScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
  });

  @override
  State<AdminSideMenuScaffold> createState() => _AdminSideMenuScaffoldState();
}

class _AdminSideMenuScaffoldState extends State<AdminSideMenuScaffold> {
  bool isExpanded = false;
  int? hoveredIndex;

  final menuItems = [
    {
      'icon': Icons.music_note,
      'label': 'Songs',
      'builder': (context) => const SongSearchPage()
    },
    {
      'icon': Icons.album,
      'label': 'Albums',
      'builder': (context) => const AlbumSearchPage()
    },
    {
      'icon': Icons.mic,
      'label': 'Artists',
      'builder': (context) => const ArtistSearchPage()
    },
    {
      'icon': Icons.type_specimen,
      'label': 'Genres',
      'builder': (context) => const GenreSearchPage()
    },
    {
      'icon': Icons.person,
      'label': 'Users',
      'builder': (context) => const AdminUserSearchPage()
    },
    {
      'icon': Icons.recommend,
      'label': 'Recommendations',
      'builder': (context) => const AdminRecommenderPage()
    },
    {
      'icon': Icons.analytics,
      'label': 'Analytics',
      'builder': (context) => const AdminAnalyticsPage()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isExpanded ? 230 : 54,
            color: AppColors.backgroundLighter2,
            child: Column(
              children: [
                _buildMenuHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final isActive = widget.selectedIndex == index;
                      final isHovered = hoveredIndex == index;

                      return MouseRegion(
                        onEnter: (_) => setState(() => hoveredIndex = index),
                        onExit: (_) => setState(() => hoveredIndex = null),
                        child: InkWell(
                          onTap: () {
                            if (widget.selectedIndex != index) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminSideMenuScaffold(
                                    body: (item['builder'] as Widget Function(
                                        BuildContext))(context),
                                    selectedIndex: index,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            color: isActive
                                ? AppColors.secondary2
                                : (isHovered
                                    ? AppColors.backgroundLighter
                                    : Colors.transparent),
                            padding: const EdgeInsets.only(
                              left: 14,
                              right: 10,
                              top: 12,
                              bottom: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item['icon'] as IconData,
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.white54),
                                if (isExpanded) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      item['label'] as String,
                                      style: TextStyle(
                                        color: isActive
                                            ? AppColors.white
                                            : AppColors.white54,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4, left: 6, right: 4),
      color: isExpanded ? AppColors.primary : AppColors.backgroundLighter2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isExpanded)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminHomePage()),
                      (route) => false,
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'melo',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.arrow_back_ios : Icons.menu,
              color: AppColors.white,
            ),
            onPressed: () => setState(() => isExpanded = !isExpanded),
          ),
        ],
      ),
    );
  }
}
