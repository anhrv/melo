import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/recommendations_response.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class RecommenderService {
  final BuildContext context;
  late final http.Client _client;

  RecommenderService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<RecommendationResponse?> getRecommendations(
      BuildContext context) async {
    final url = Uri.parse(ApiConstants.getRecommendations).replace(
      queryParameters: {
        'size': '10',
      },
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return RecommendationResponse.fromJson(json.decode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<void> trainModels() async {
    final url = Uri.parse(ApiConstants.trainModels);
    final response = await _client.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Models trained successfully",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
    }
  }
}
