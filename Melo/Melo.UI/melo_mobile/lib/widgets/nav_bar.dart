import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/pages/library_page.dart';
import 'package:melo_mobile/pages/search_page.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const SearchPage();
        break;
      case 1:
        targetPage = const HomePage();
        break;
      case 2:
        targetPage = const LibraryPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.white70,
            width: 0.2,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 4),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigate(context, index),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark,
              size: 24,
            ),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}
