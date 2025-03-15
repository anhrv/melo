import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/pages/stripe_checkout_page.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

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

      Map<String, dynamic> payload = JwtDecoder.decode(accessToken);

      List<dynamic> roles = [];
      var rolesData = payload[
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
      if (rolesData is String) {
        roles = [rolesData];
      } else if (rolesData is List) {
        roles = List<String>.from(rolesData);
      }
      bool isAdmin = roles.contains("Admin");

      bool isSubscribed =
          payload['subscribed']?.toString().toLowerCase() == 'true';

      if (isAdmin || isSubscribed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StripeCheckoutPage()),
        );
      }
    } else {
      ApiErrorHandler.handleErrorResponse(
          response.body, context, onFieldErrors);
    }
  }

  Future<void> register(
    String? firstName,
    String? lastName,
    String username,
    String email,
    String password,
    String confirmPassword,
    Function(Map<String, String>) onFieldErrors,
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.register);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'passwordInput': password,
        'passwordConfirm': confirmPassword,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.setAccessToken(accessToken);
      await TokenStorage.setRefreshToken(refreshToken);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StripeCheckoutPage()),
      );
    } else {
      ApiErrorHandler.handleErrorResponse(
          response.body, context, onFieldErrors);
    }
  }
}
