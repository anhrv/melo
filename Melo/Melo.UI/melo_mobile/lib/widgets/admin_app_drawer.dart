import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/admin_genre_search_page.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class AdminAppDrawer extends StatelessWidget {
  const AdminAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          Container(
            height: 71.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.white70,
                  width: 0.2,
                ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 4.0,
            ),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'melo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListTileWithBorder(
                  context,
                  Icons.music_note,
                  'Songs',
                  const HomePage(),
                ),
                _buildListTileWithBorder(
                  context,
                  Icons.album,
                  'Albums',
                  const HomePage(),
                ),
                _buildListTileWithBorder(
                  context,
                  Icons.mic,
                  'Artists',
                  const HomePage(),
                ),
                _buildListTileWithBorder(
                  context,
                  Icons.type_specimen,
                  'Genres',
                  const AdminGenreSearchPage(),
                ),
                _buildListTileWithBorder(
                  context,
                  Icons.person,
                  'Users',
                  const HomePage(),
                ),
                _buildListTileWithBorder(
                  context,
                  Icons.recommend,
                  'Recommender',
                  const HomePage(),
                ),
                _buildListTile(
                  context,
                  Icons.analytics,
                  'Analytics',
                  const HomePage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTileWithBorder(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.white70,
            width: 0.15,
          ),
        ),
      ),
      child: _buildListTile(context, icon, title, screen),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      minLeadingWidth: 24,
      leading: Icon(icon, color: AppColors.white, size: 24),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: () => _navigateToScreen(context, screen),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
