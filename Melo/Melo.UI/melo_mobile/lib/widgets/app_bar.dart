import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(48.0 + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      surfaceTintColor: AppColors.white,
      titleSpacing: 0,
      leading: isAdmin
          ? IconButton(
              icon: Icon(canPop ? Icons.arrow_back : Icons.menu),
              onPressed: () {
                if (canPop) {
                  Navigator.of(context).pop();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(left: isAdmin ? 0.0 : 20.0),
        child: Text(
          title ?? 'melo',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                color: AppColors.white,
              ),
            ),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
      bottom: bottom,
    );
  }
}
