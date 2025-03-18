import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:melo_mobile/themes/app_colors.dart';

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
        showSnackBar(globalMessages.join('\n'), context);
      }

      if (onFieldErrors != null && fieldErrors.isNotEmpty && context.mounted) {
        onFieldErrors(fieldErrors);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar('An unexpected error occurred.', context);
      }
    }
  }

  static void showSnackBar(String message, BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
