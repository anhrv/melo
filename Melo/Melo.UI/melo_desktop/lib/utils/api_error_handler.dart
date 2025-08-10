import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/themes/app_colors.dart';

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
    Flushbar(
      message: message,
      messageSize: 16,
      messageColor: AppColors.white,
      backgroundColor: AppColors.redAccent,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      maxWidth: 500,
    ).show(context);
  }
}
