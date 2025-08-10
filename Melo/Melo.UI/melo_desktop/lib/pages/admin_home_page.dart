import 'package:flutter/material.dart';
import 'package:melo_desktop/pages/album_search_page.dart';
import 'package:melo_desktop/pages/admin_analytics_page.dart';
import 'package:melo_desktop/pages/artist_search_page.dart';
import 'package:melo_desktop/pages/genre_search_page.dart';
import 'package:melo_desktop/pages/admin_recommender_page.dart';
import 'package:melo_desktop/pages/song_search_page.dart';
import 'package:melo_desktop/pages/admin_user_search_page.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/admin_side_menu.dart';
import 'package:melo_desktop/widgets/app_bar.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  final List<_MenuItem> menuItems = const [
    _MenuItem(
      icon: Icons.music_note,
      label: 'Songs',
      screen: SongSearchPage(),
    ),
    _MenuItem(
      icon: Icons.album,
      label: 'Albums',
      screen: AlbumSearchPage(),
    ),
    _MenuItem(
      icon: Icons.mic,
      label: 'Artists',
      screen: ArtistSearchPage(),
    ),
    _MenuItem(
      icon: Icons.type_specimen,
      label: 'Genres',
      screen: GenreSearchPage(),
    ),
    _MenuItem(
      icon: Icons.person,
      label: 'Users',
      screen: AdminUserSearchPage(),
    ),
    _MenuItem(
      icon: Icons.recommend,
      label: 'Recommender',
      screen: AdminRecommenderPage(),
    ),
    _MenuItem(
      icon: Icons.analytics,
      label: 'Analytics',
      screen: AdminAnalyticsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminSideMenuScaffold(
      selectedIndex: -1,
      body: Scaffold(
        appBar: const CustomAppBar(title: 'Home'),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 480,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildHorizontalCard(
                icon: item.icon,
                label: item.label,
                onTap: () => _navigateToScreen(context, item.screen, index),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.white70,
          width: 0.2,
        ),
      ),
      color: AppColors.background,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen, int targetIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSideMenuScaffold(
          body: screen,
          selectedIndex: targetIndex,
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
