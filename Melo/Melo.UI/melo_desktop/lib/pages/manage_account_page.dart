import 'package:flutter/material.dart';
import 'package:melo_desktop/pages/edit_account_page.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/admin_side_menu.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
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
      child: AdminSideMenuScaffold(
        selectedIndex: -1,
        body: Scaffold(
          appBar: CustomAppBar(
            title: "Manage account",
          ),
          body: ListView(
            padding: EdgeInsets.all(32),
            children: [
              _buildListTileWithBorder(
                title: 'Edit account',
                onTap: () =>
                    _navigateToScreen(context, const EditAccountPage(), -1),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildExpandableDeleteAccount(),
              const SizedBox(
                height: 20,
              ),
              _buildLogoutTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTileWithBorder(
      {required String title, VoidCallback? onTap}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1250),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.white70,
              width: 0.2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            minLeadingWidth: 24,
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDeleteAccount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1250),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.white70,
              width: 0.2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              'Delete account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        _isDeleteAccountExpanded ? AppColors.secondary : null,
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Admins cannot delete their own accounts. If your account needs to be deleted, another admin must delete it for you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.redAccent,
                        ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return _buildListTileWithBorder(
      title: 'Logout',
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen, int targetIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSideMenuScaffold(
          body: screen,
          selectedIndex: targetIndex,
        ),
      ),
    );
  }
}
