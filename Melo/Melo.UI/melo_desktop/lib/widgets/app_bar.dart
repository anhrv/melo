import 'package:flutter/material.dart';
import 'package:melo_desktop/pages/manage_account_page.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
  }

  Future<void> _logout() async {
    try {
      await _authService.logout(context);
    } catch (ex) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return AppBar(
      surfaceTintColor: AppColors.white,
      titleSpacing: canPop ? 0 : 16,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(left: 0.0),
        child: Text(
          widget.title ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      actions: [
        if (user != null)
          PopupMenuButton<int>(
            tooltip: '',
            offset: const Offset(0, 48),
            color: AppColors.background,
            surfaceTintColor: Colors.white,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.account_box, color: AppColors.white),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('Manage account',
                        style: TextStyle(color: AppColors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.white),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('Logout', style: TextStyle(color: AppColors.white)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageAccountPage()),
                );
              } else if (value == 1) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 22,
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: 400,
                      child: const Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    backgroundColor: AppColors.backgroundLighter2,
                    surfaceTintColor: Colors.transparent,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.white,
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _logout();
                        },
                        child: const Text('Yes',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.white,
                            )),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.userName ?? 'Guest',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 12,
                        height: 1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
      ],
      bottom: widget.bottom,
    );
  }
}
