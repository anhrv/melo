import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_desktop/constants/api_constants.dart';
import 'package:melo_desktop/interceptors/auth_interceptor.dart';
import 'package:melo_desktop/models/user_response.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/models/paged_response.dart';
import 'package:melo_desktop/utils/api_error_handler.dart';

class UserService {
  final BuildContext context;
  late final http.Client _client;

  UserService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<UserResponse>?> get(
    BuildContext context, {
    required int page,
    String? username,
    String? firstname,
    String? lastname,
    String? email,
    List<int>? roleIds,
    bool? isDeleted,
    bool? isSubscribed,
    String? sortBy,
    bool? ascending,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': '25',
      if (username != null && username.isNotEmpty) 'userName': username,
      if (firstname != null && firstname.isNotEmpty) 'firstName': firstname,
      if (lastname != null && lastname.isNotEmpty) 'lastName': lastname,
      if (email != null && email.isNotEmpty) 'email': email,
      if (roleIds != null && roleIds.isNotEmpty)
        'roleIds': roleIds.map((id) => id.toString()).toList(),
      if (isDeleted != null) 'deleted': isDeleted.toString(),
      if (isSubscribed != null) 'subscribed': isSubscribed.toString(),
      if (email != null && email.isNotEmpty) 'email': email,
      if (sortBy != null) 'sortBy': sortBy,
      if (ascending != null) 'ascending': ascending.toString(),
    };

    final url = Uri.parse(ApiConstants.user).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<UserResponse>.fromJson(
          json.decode(response.body), UserResponse.fromJson);
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<List<LovResponse>> getLov(
    BuildContext context, {
    String? name,
  }) async {
    final queryParams = <String, dynamic>{
      "pageSize": "25",
      if (name != null && name.isNotEmpty) 'name': name,
    };

    final url = Uri.parse("${ApiConstants.user}/lov").replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      PagedResponse<LovResponse> res = PagedResponse<LovResponse>.fromJson(
          json.decode(response.body), LovResponse.fromJson);
      return res.data;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return [];
    }
  }

  Future<UserResponse?> getById(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.user}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          null,
        );
      }
      return null;
    }
  }

  Future<UserResponse?> create(
    String username,
    String? firstname,
    String? lastname,
    String email,
    String password,
    String confirmPassword,
    List<int>? roleIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse(ApiConstants.user);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': username,
        if (firstname != null && firstname.isNotEmpty) 'firstName': firstname,
        if (lastname != null && lastname.isNotEmpty) 'lastName': lastname,
        'email': email,
        'passwordInput': password,
        'passwordConfirm': confirmPassword,
        if (roleIds != null && roleIds.isNotEmpty)
          'roleIds': roleIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 201) {
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          onFieldErrors,
        );
      }
      return null;
    }
  }

  Future<UserResponse?> update(
    int userId,
    String newUsername,
    String? newFirstname,
    String? newLastname,
    String newEmail,
    String? newPassword,
    String? newConfirmPassword,
    List<int>? roleIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse('${ApiConstants.user}/$userId');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': newUsername,
        'firstName': newFirstname,
        'lastName': newLastname,
        'email': newEmail,
        if (newPassword != null && newPassword.isNotEmpty)
          'newPassword': newPassword,
        if (newConfirmPassword != null && newConfirmPassword.isNotEmpty)
          'passwordConfirm': newConfirmPassword,
        if (roleIds != null && roleIds.isNotEmpty)
          'roleIds': roleIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          onFieldErrors,
        );
      }
      return null;
    }
  }

  Future<bool> cancelSubscription(
    int userId,
    BuildContext context,
  ) async {
    final url = Uri.parse('${ApiConstants.user}/$userId/cancel-subscription');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          null,
        );
      }
      return false;
    }
  }

  Future<bool> delete(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.user}/$id");

    final response = await _client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return false;
    }
  }
}
