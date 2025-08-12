import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_desktop/constants/api_constants.dart';
import 'package:melo_desktop/interceptors/auth_interceptor.dart';
import 'package:melo_desktop/utils/api_error_handler.dart';
import 'package:melo_desktop/utils/toast_util.dart';

class RecommenderService {
  final BuildContext context;
  late final http.Client _client;

  RecommenderService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<void> trainModels() async {
    final url = Uri.parse(ApiConstants.trainModels);
    final response = await _client.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        ToastUtil.showToast("Models trained successfully", false, context);
      }
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
    }
  }
}
