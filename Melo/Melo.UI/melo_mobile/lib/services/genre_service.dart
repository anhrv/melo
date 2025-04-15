import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/genre_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class GenreService {
  final BuildContext context;
  late final http.Client _client;

  GenreService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<GenreResponse>?> get(
    BuildContext context, {
    required int page,
    String? name,
    String? sortBy,
    bool? ascending,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': '25',
      if (name != null && name.isNotEmpty) 'name': name,
      if (sortBy != null) 'sortBy': sortBy,
      if (ascending != null) 'ascending': ascending.toString(),
    };

    final url = Uri.parse(ApiConstants.genre).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<GenreResponse>.fromJson(
          json.decode(response.body), GenreResponse.fromJson);
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<bool> delete(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.genre}/$id");

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
