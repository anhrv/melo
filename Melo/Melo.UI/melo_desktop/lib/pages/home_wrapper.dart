import 'package:flutter/material.dart';
import 'package:melo_desktop/models/user_response.dart';
import 'package:melo_desktop/pages/admin_home_page.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomePage()),
            (route) => false,
          );
        });
      }
      return;
    } catch (e) {
      //
    }
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
