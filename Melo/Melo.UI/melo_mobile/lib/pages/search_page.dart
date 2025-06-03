import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/album_search_page.dart';
import 'package:melo_mobile/pages/artist_search_page.dart';
import 'package:melo_mobile/pages/genre_search_page.dart';
import 'package:melo_mobile/pages/song_search_page.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/nav_bar.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Search',
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
                Tab(text: 'Songs'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Genres'),
              ],
            ),
          ),
          endDrawer: const UserDrawer(),
          bottomNavigationBar: const BottomNavBar(currentIndex: 0),
          body: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.white, width: 0.2),
              ),
            ),
            child: const TabBarView(
              children: [
                SongSearchPage(
                  currentIndex: 0,
                ),
                AlbumSearchPage(
                  currentIndex: 0,
                ),
                ArtistSearchPage(
                  currentIndex: 0,
                ),
                GenreSearchPage(
                  currentIndex: 0,
                ),
              ],
            ),
          ),
        ));
  }
}
