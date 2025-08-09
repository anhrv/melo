import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_desktop/constants/api_constants.dart';
import 'package:melo_desktop/pages/login_page.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/storage/token_storage.dart';
import 'package:melo_desktop/utils/api_error_handler.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';

class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final BuildContext? _context;
  static final Lock _refreshLock = Lock();
  static Completer<void>? _refreshCompleter;
  static bool _isRefreshing = false;

  AuthInterceptor(this._inner, [this._context]);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_shouldSkipInterceptor(request.url.toString())) {
      return _inner.send(request);
    }

    await _refreshLock.synchronized(() async {
      if (_isTokenExpiringSoon(await TokenStorage.getAccessToken())) {
        await _attemptTokenRefresh();
      }
    });

    final modifiedRequest = await _addAuthorizationHeader(request);
    final response = await _inner.send(modifiedRequest);

    return _handleResponse(response);
  }

  Future<http.BaseRequest> _addAuthorizationHeader(
      http.BaseRequest request) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    return request;
  }

  Future<void> checkRefresh() async {
    await _refreshLock.synchronized(() async {
      if (_isTokenExpiringSoon(await TokenStorage.getAccessToken())) {
        await _attemptTokenRefresh();
      }
    });
  }

  Future<void> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer();

    try {
      final success = await _refreshTokens();
      if (!success) throw Exception('Token refresh failed');
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    final accessToken = await TokenStorage.getAccessToken();

    if (refreshToken == null || accessToken == null) {
      _logoutUser();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.refreshToken),
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

      _handleRefreshError(response.statusCode);
      return false;
    } catch (e) {
      _logoutUser();
      return false;
    }
  }

  void _handleRefreshError(int statusCode) {
    if (_context != null && _context.mounted) {
      ApiErrorHandler.showSnackBar(
          "Session expired. Please log in again.", _context);
      _logoutUser();
    }
  }

  Future<http.StreamedResponse> _handleResponse(
      http.StreamedResponse response) async {
    if (response.statusCode == 401) {
      if (_context != null && _context.mounted) {
        ApiErrorHandler.showSnackBar(
            "An error occurred. Please login again.", _context);
      }
      _logoutUser();
      throw Exception('Authentication required');
    }
    return response;
  }

  bool _shouldSkipInterceptor(String url) {
    return url.contains(ApiConstants.login);
  }

  bool _isTokenExpiringSoon(String? token) {
    if (token == null) return true;
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      return expiryDate
          .isBefore(DateTime.now().add(const Duration(minutes: 3)));
    } catch (e) {
      return true;
    }
  }

  void _logoutUser() {
    TokenStorage.clearTokens();
    if (_context != null && _context.mounted) {
      Provider.of<UserProvider>(_context, listen: false).clearUser();
      Navigator.pushAndRemoveUntil(
        _context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
