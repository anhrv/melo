import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/admin_home_page.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class HomeWrapper extends StatefulWidget {
  final bool checkUser;

  const HomeWrapper({
    super.key,
    this.checkUser = true,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late bool _checkUser;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _checkUser = widget.checkUser;
    _authService = AuthService(context);
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      if (!_checkUser) {
        final isAdmin = await _authService.isAdminUser();
        _navigateBasedOnRole(isAdmin);
        return;
      }

      final user = await _authService.getCurrentUser(context);

      if (user != null) {
        final isAdmin = await _authService.isAdminUser();
        _navigateBasedOnRole(isAdmin);
      }

      return;
    } catch (e) {
      //
    }
  }

  void _navigateBasedOnRole(bool isAdmin) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => isAdmin ? const AdminHomePage() : const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _checkUser
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
