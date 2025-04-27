import 'package:flutter/material.dart';
import 'package:melo_mobile/models/user_response.dart';
import 'package:melo_mobile/pages/edit_account_page.dart';
import 'package:melo_mobile/pages/stripe_checkout_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/services/subscription_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/utils/datetime_util.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class ManageAccountPage extends StatefulWidget {
  const ManageAccountPage({super.key});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  bool _isLoading = false;
  bool _isSubscriptionExpanded = false;
  bool _isDeleteAccountExpanded = false;
  late AuthService _authService;
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
    _subscriptionService = SubscriptionService(context);
  }

  void _deleteAccount() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authService.deleteAccount(
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

  void _cancelSubscription() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _subscriptionService.cancelSubscription();
    } catch (ex) {
      //
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

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
            userProvider.isAdmin
                ? const SizedBox.shrink()
                : _buildExpandableSubscription(user),
            _buildExpandableDeleteAccount(userProvider.isAdmin),
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
                Row(
                  children: [
                    Text(
                      'Start date:   ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      user != null && user.subscriptionStart != null
                          ? DateTimeUtil.formatUtcToLocal(
                              user.subscriptionStart.toString())
                          : 'N/A',
                      style: const TextStyle(
                          color: AppColors.white54, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'End date:   ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      user != null && user.subscriptionEnd != null
                          ? DateTimeUtil.formatUtcToLocal(
                              user.subscriptionEnd.toString())
                          : 'N/A',
                      style: const TextStyle(
                          color: AppColors.white54, fontSize: 15),
                    ),
                  ],
                ),
                if (user != null && user.subscribed == true) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
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
                                  'Cancel subscription',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.redAccent,
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
                            'Are you sure you want to cancel your subscription? You cannot use the app unless you are a subscribed user.',
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
                                _cancelSubscription();
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                if (user != null && user.subscribed != true) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StripeCheckoutPage()),
                      );
                    },
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
                    onPressed: () {
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
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.redAccent,
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
                            'Are you sure you want to delete your account?',
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
                                _deleteAccount();
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
