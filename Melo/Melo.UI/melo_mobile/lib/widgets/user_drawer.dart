import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:provider/provider.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  bool _isLoading = false;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
  }

  void _logout() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _authService.logout(
        context,
      );
    } catch (ex) {
      //
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      width: 250,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          Container(
            height: 71.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.backgroundLighter,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.white70,
                  width: 0.2,
                ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 0.0,
            ),
            alignment: Alignment.bottomLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    color: AppColors.backgroundLighter,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? (user.userName ?? 'Guest') : 'Guest',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.white70,
                        width: 0.15,
                      ),
                    ),
                  ),
                  child: ListTile(
                    minLeadingWidth: 24,
                    leading: const Icon(
                      Icons.account_box,
                      color: AppColors.white,
                      size: 24,
                    ),
                    title: Text(
                      'Manage account',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () => _navigateToScreen(context, const HomePage()),
                  ),
                ),
                ListTile(
                  minLeadingWidth: 24,
                  leading: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.secondary),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.logout,
                          color: AppColors.white,
                          size: 24,
                        ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: _isLoading ? AppColors.secondary : AppColors.white,
                    ),
                  ),
                  onTap: _logout,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}
