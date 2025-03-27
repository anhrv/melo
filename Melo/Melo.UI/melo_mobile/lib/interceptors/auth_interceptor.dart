import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/pages/login_page.dart';
import 'package:melo_mobile/pages/stripe_checkout_page.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final BuildContext _context;

  AuthInterceptor(this._inner, this._context);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_shouldSkipInterceptor(request.url.toString())) {
      return _inner.send(request);
    }

    String? accessToken = await TokenStorage.getAccessToken();
    String? refreshToken = await TokenStorage.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      _logoutUser();
      throw Exception('Login needed');
    }

    if (_isTokenExpiringSoon(accessToken)) {
      bool refreshed = await _refreshTokens(accessToken, refreshToken);
      if (!refreshed) {
        _logoutUser();
        throw Exception('Session expired');
      }
      accessToken = await TokenStorage.getAccessToken();
    }

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      if (_context.mounted) {
        ApiErrorHandler.showSnackBar(
            "An error occurred. Please login again.", _context);
      }
      _logoutUser();
      throw Exception('Login needed');
    }

    if (response.statusCode == 402) {
      if (_context.mounted) {
        ApiErrorHandler.showSnackBar(
            "Subscription has expired. Please subscribe again.", _context);
        Navigator.pushReplacement(
          _context,
          MaterialPageRoute(
            builder: (context) => const StripeCheckoutPage(),
          ),
        );
      }
      throw Exception('Subscription expired');
    }

    return response;
  }

  bool _shouldSkipInterceptor(String url) {
    return url.contains(ApiConstants.login) ||
        url.contains(ApiConstants.register);
  }

  bool _isTokenExpiringSoon(String token) {
    try {
      DateTime expiryDate = JwtDecoder.getExpirationDate(token);
      return expiryDate
          .isBefore(DateTime.now().add(const Duration(minutes: 3)));
    } catch (e) {
      return true;
    }
  }

  Future<bool> _refreshTokens(String? accessToken, String? refreshToken) async {
    if (accessToken == null || refreshToken == null) return false;

    final url = Uri.parse(ApiConstants.refreshToken);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.setAccessToken(data['accessToken']);
      await TokenStorage.setRefreshToken(data['refreshToken']);
      return true;
    }

    if (_context.mounted) {
      ApiErrorHandler.showSnackBar(
        "Session expired. Please log in again.",
        _context,
      );
    }
    return false;
  }

  void _logoutUser() {
    TokenStorage.clearTokens();
    if (_context.mounted) {
      Provider.of<UserProvider>(_context, listen: false).clearUser();
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }
}
