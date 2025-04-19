import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/admin_artist_search_page.dart';
import 'package:melo_mobile/pages/admin_genre_search_page.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const AdminAppDrawer(),
      endDrawer: const UserDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHorizontalCard(
              icon: Icons.music_note,
              label: 'Songs',
              onTap: () => _navigateToScreen(context, const HomePage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.album,
              label: 'Albums',
              onTap: () => _navigateToScreen(context, const HomePage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.mic,
              label: 'Artists',
              onTap: () =>
                  _navigateToScreen(context, const AdminArtistSearchPage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.type_specimen,
              label: 'Genres',
              onTap: () =>
                  _navigateToScreen(context, const AdminGenreSearchPage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.person,
              label: 'Users',
              onTap: () => _navigateToScreen(context, const HomePage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.recommend,
              label: 'Recommender',
              onTap: () => _navigateToScreen(context, const HomePage()),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCard(
              icon: Icons.analytics,
              label: 'Analytics',
              onTap: () => _navigateToScreen(context, const HomePage()),
            ),
          ],
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
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }
}
