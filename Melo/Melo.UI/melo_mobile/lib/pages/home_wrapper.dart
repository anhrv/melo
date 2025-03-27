import 'package:flutter/material.dart';
import 'package:melo_mobile/models/user_response.dart';
import 'package:melo_mobile/pages/admin_home_page.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:provider/provider.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({
    super.key,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userData = await _authService.getCurrentUser(context);
      if (userData != null) {
        final user = UserResponse.fromJson(userData);
        userProvider.setUser(user);
        _navigateBasedOnRole(userProvider.isAdmin);
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
      ),
    );
  }
}
