import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/themes/app_colors.dart';

class ToastUtil {
  static void showToast(String message, bool error, BuildContext context) {
    Flushbar(
      message: message,
      messageSize: 16,
      messageColor: AppColors.white,
      backgroundColor: error ? AppColors.redAccent : AppColors.greenAccent,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      maxWidth: 500,
    ).show(context);
  }
}
