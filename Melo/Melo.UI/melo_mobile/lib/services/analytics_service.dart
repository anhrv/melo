import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class AnalyticsService {
  final BuildContext context;
  late final http.Client _client;

  AnalyticsService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<List<Map<String, dynamic>>?> get(
    BuildContext context, {
    required int amount,
    required String entity,
    required String sortBy,
    required bool ascending,
  }) async {
    final queryParams = <String, dynamic>{
      'page': "1",
      'pagesize': amount.toString(),
      'sortBy': sortBy,
      'ascending': ascending.toString(),
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/$entity').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final paged = PagedResponse<Map<String, dynamic>>.fromJson(
        json,
        (e) => Map<String, dynamic>.from(e),
      );
      return paged.data;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }
}
