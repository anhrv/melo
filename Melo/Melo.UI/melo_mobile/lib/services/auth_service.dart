import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class AuthService {
  Future<void> login(
    String emailUsername,
    String passwordInput,
    Function(Map<String, String>) onFieldErrors,
    BuildContext context,
  ) async {
    final url = Uri.parse(ApiConstants.login);
    final response = await http.post(
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
    final response = await http.post(
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.setAccessToken(accessToken);
      await TokenStorage.setRefreshToken(refreshToken);
    } else {
      ApiErrorHandler.handleErrorResponse(
          response.body, context, onFieldErrors);
    }
  }

  Future<Map<String, dynamic>> getData(BuildContext context) async {
    final url = Uri.parse(ApiConstants.genre);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await TokenStorage.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      ApiErrorHandler.handleErrorResponse(response.body, context, null);
      throw Exception('Failed to fetch data');
    }
  }
}
