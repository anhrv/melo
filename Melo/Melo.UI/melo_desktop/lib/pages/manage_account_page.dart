import 'package:flutter/material.dart';
import 'package:melo_desktop/pages/edit_account_page.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';

class ManageAccountPage extends StatefulWidget {
  const ManageAccountPage({super.key});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  bool _isLoading = false;
  bool _isDeleteAccountExpanded = false;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
  }

  void _logout() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: AppColors.white,
          titleSpacing: 0,
          title: const Text(
            'Manage account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
        body: ListView(
          children: [
            _buildListTileWithBorder(
              title: 'Edit account',
              onTap: () => _navigateToScreen(context, const EditAccountPage()),
            ),
            _buildExpandableDeleteAccount(),
            _buildLogoutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileWithBorder(
      {required String title, VoidCallback? onTap}) {
    return Container(
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
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExpandableDeleteAccount() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.white70,
            width: 0.15,
          ),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          'Delete account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _isDeleteAccountExpanded ? AppColors.secondary : null,
              ),
        ),
        trailing: RotationTransition(
          turns: _isDeleteAccountExpanded
              ? const AlwaysStoppedAnimation(0.5)
              : const AlwaysStoppedAnimation(0),
          child: Icon(
            Icons.arrow_downward,
            size: 20,
            color: _isDeleteAccountExpanded
                ? AppColors.secondary
                : AppColors.white54,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() => _isDeleteAccountExpanded = expanded);
        },
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admins cannot delete their own accounts. If your account needs to be deleted, another admin must delete it for you.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.redAccent,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      minLeadingWidth: 24,
      title: Text(
        'Logout',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
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
                      fontSize: 18,
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
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No',
                    style: TextStyle(
                      fontSize: 16,
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
                      fontSize: 16,
                      color: AppColors.white,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
