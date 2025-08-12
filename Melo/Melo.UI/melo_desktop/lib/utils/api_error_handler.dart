import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:melo_desktop/utils/toast_util.dart';

class ApiErrorHandler {
  static void handleErrorResponse(
    String responseBody,
    BuildContext context,
    Function(Map<String, String>)? onFieldErrors,
  ) {
    try {
      final Map<String, dynamic> errorResponse = jsonDecode(responseBody);
      List<String> globalMessages = [];
      Map<String, String> fieldErrors = {};

      if (errorResponse.containsKey('errors') &&
          errorResponse['errors'] is Map<String, dynamic>) {
        final errors = errorResponse['errors'];

        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            if (key.toLowerCase() == "error") {
              globalMessages.addAll(value.map((e) => e.toString()));
            } else {
              fieldErrors[key] = value.join('\n');
            }
          }
        });
      }

      if (globalMessages.isNotEmpty && context.mounted) {
        showToast(globalMessages.join('\n'), context);
      }

      if (onFieldErrors != null && fieldErrors.isNotEmpty && context.mounted) {
        onFieldErrors(fieldErrors);
      }
    } catch (e) {
      if (context.mounted) {
        showToast('An unexpected error occurred.', context);
      }
    }
  }

  static void showToast(String message, BuildContext context) {
    ToastUtil.showToast(message, true, context);
  }
}
