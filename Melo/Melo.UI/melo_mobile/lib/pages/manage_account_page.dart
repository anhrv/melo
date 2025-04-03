import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melo_mobile/models/user_response.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:provider/provider.dart';

class ManageAccountPage extends StatefulWidget {
  const ManageAccountPage({super.key});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  bool _isSubscriptionExpanded = false;
  bool _isDeleteAccountExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        titleSpacing: 0,
        title: const Text(
          'Manage account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildListTileWithBorder(
            title: 'Edit account',
            onTap: () => _navigateToScreen(context, const HomePage()),
          ),
          userProvider.isAdmin
              ? const SizedBox.shrink()
              : _buildExpandableSubscription(user),
          _buildExpandableDeleteAccount(userProvider.isAdmin),
          _buildLogoutTile(),
        ],
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

  Widget _buildExpandableSubscription(UserResponse? user) {
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
          'Subscription',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _isSubscriptionExpanded ? AppColors.secondary : null,
              ),
        ),
        trailing: RotationTransition(
          turns: _isSubscriptionExpanded
              ? const AlwaysStoppedAnimation(0.5)
              : const AlwaysStoppedAnimation(0),
          child: Icon(
            Icons.arrow_downward,
            size: 20,
            color: _isSubscriptionExpanded
                ? AppColors.secondary
                : AppColors.white54,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() => _isSubscriptionExpanded = expanded);
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
                Row(
                  children: [
                    Text(
                      'Subscribed: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (user != null && user.subscribed != null)
                      Icon(
                        user.subscribed! ? Icons.check_circle : Icons.cancel,
                        color: user.subscribed!
                            ? AppColors.greenAccent
                            : AppColors.redAccent,
                        size: 20,
                      )
                    else
                      Text(
                        'N/A',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Start date: ${user != null && user.subscriptionStart != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(user.subscriptionStart!.microsecondsSinceEpoch, isUtc: true)) : 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'End date: ${user != null && user.subscriptionEnd != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(user.subscriptionEnd!.microsecondsSinceEpoch, isUtc: true)) : 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (user != null && user.subscribed == true) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {/* Cancel logic */},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      'Cancel Subscription',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                if (user != null && user.subscribed != true) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {/* Subscribe logic */},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      'Subscribe',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDeleteAccount(bool isAdmin) {
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
                isAdmin
                    ? Text(
                        'Admins cannot delete their own accounts. If your account needs to be deleted, another admin must delete it for you.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.redAccent,
                            ),
                      )
                    : Text(
                        'This action is permanent. You will not be able to get your account back and all of your data will be deleted.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.redAccent,
                            ),
                      ),
                if (!isAdmin) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {/* Add delete logic */},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      'Delete',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
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
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Add logout logic
                },
                child: const Text('Logout'),
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
