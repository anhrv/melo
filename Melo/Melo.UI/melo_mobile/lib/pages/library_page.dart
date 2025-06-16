import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/album_search_page.dart';
import 'package:melo_mobile/pages/artist_search_page.dart';
import 'package:melo_mobile/pages/playlist_search_page.dart';
import 'package:melo_mobile/pages/song_search_page.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/app_shell.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String? _activeLikedSection;

  void _openLikedSection(String section) {
    setState(() {
      _activeLikedSection = section;
    });
  }

  void _goBackToLikedOptions() {
    setState(() {
      _activeLikedSection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Library',
            bottom: TabBar(
              indicatorColor: Colors.transparent,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.white70,
              labelStyle: TextStyle(fontSize: 14),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.transparent;
                  }
                  return null;
                },
              ),
              tabs: [
                Tab(text: 'Liked'),
                Tab(text: 'Playlists'),
              ],
            ),
          ),
          endDrawer: const UserDrawer(),
          drawerScrimColor: Colors.black.withOpacity(0.4),
          bottomNavigationBar: const BottomNavBar(currentIndex: 2),
          body: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.white, width: 0.2),
              ),
            ),
            child: TabBarView(
              children: [
                _buildLikedTab(context),
                PlaylistSearchPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikedTab(BuildContext context) {
    switch (_activeLikedSection) {
      case 'songs':
        return _buildSubPageWrapper(
          context,
          title: 'Songs',
          child: SongSearchPage(liked: true, currentIndex: 2),
        );
      case 'albums':
        return _buildSubPageWrapper(
          context,
          title: 'Albums',
          child: AlbumSearchPage(liked: true, currentIndex: 2),
        );
      case 'artists':
        return _buildSubPageWrapper(
          context,
          title: 'Artists',
          child: ArtistSearchPage(liked: true, currentIndex: 2),
        );
      default:
        return _buildOptionList(context);
    }
  }

  Widget _buildSubPageWrapper(BuildContext context,
      {required String title, required Widget child}) {
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: _goBackToLikedOptions,
              ),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, color: AppColors.secondary),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildOptionList(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          title: 'Songs',
          icon: Icons.music_note,
          onTap: () => _openLikedSection('songs'),
        ),
        _buildOptionTile(
          context,
          title: 'Albums',
          icon: Icons.album,
          onTap: () => _openLikedSection('albums'),
        ),
        _buildOptionTile(
          context,
          title: 'Artists',
          icon: Icons.mic,
          onTap: () => _openLikedSection('artists'),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context,
      {required String title, required icon, required VoidCallback onTap}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.white70,
            width: 0.2,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
        ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        contentPadding: const EdgeInsets.only(
          left: 16,
          right: 0,
          top: 8,
          bottom: 8,
        ),
        onTap: onTap,
      ),
    );
  }
}
