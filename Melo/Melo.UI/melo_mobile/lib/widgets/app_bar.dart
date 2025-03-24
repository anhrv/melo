import 'package:flutter/material.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  void _handleUserIconPress(BuildContext context) {
    // Navigator.push(
    // context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: AppColors.white,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text('melo'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 5.0,
          ),
          child: IconButton(
            icon: const CircleAvatar(
              backgroundColor: AppColors.white70,
              radius: 15,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.person,
                  color: AppColors.white,
                ),
              ),
            ),
            onPressed: () => _handleUserIconPress(context),
          ),
        ),
      ],
    );
  }
}
