import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_desktop/constants/api_constants.dart';
import 'package:melo_desktop/interceptors/auth_interceptor.dart';
import 'package:melo_desktop/pages/admin_home_page.dart';
import 'package:melo_desktop/pages/login_page.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/storage/token_storage.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/api_error_handler.dart';
import 'package:provider/provider.dart';

class AuthService {
  final BuildContext context;
  late final http.Client _client;

  AuthService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<void> login(
    String emailUsername,
    String passwordInput,
    Function(Map<String, String>) onFieldErrors,
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.login);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'emailUsername': emailUsername,
        'passwordInput': passwordInput,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.setAccessToken(accessToken);
      await TokenStorage.setRefreshToken(refreshToken);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
        (route) => false,
      );
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
            response.body, context, onFieldErrors);
      }
    }
  }

  Future<void> logout(
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.logout);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await TokenStorage.clearTokens();
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
    }
  }

  Future<dynamic> getCurrentUser(
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.currentUser);
    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<dynamic> updateAccount(
    String? firstName,
    String? lastName,
    String userName,
    String email,
    Function(Map<String, String>) onFieldErrors,
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.currentUser);
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'userName': userName,
        'email': email
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
            response.body, context, onFieldErrors);
      }
      return null;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirm,
    Function(Map<String, String>) onFieldErrors,
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.changePassword);
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      }),
    );

    if (response.statusCode == 200) {
      await TokenStorage.clearTokens();
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Password changed successfully. Please login again.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
            response.body, context, onFieldErrors);
      }
    }
  }
}
