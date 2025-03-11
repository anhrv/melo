import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/pages/home_page.dart';
import 'package:melo_mobile/storage/token_storage.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class SubscriptionService {
  final BuildContext context;
  late final http.Client _client;

  SubscriptionService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<void> handlePayment() async {
    final response = await createSubscription();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: response['clientSecret'],
        customerId: response['customerId'],
        merchantDisplayName: 'Melo',
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please wait for payment confirmation",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white70,
        duration: Duration(seconds: 2),
      ),
    );

    await confirmSubscription();
  }

  Future<dynamic> createSubscription() async {
    final url = Uri.parse(ApiConstants.createSubscription);
    final response = await _client.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      ApiErrorHandler.handleErrorResponse(response.body, context, null);
      return null;
    }
  }

  Future<void> confirmSubscription() async {
    final url = Uri.parse(ApiConstants.confirmSubscription);
    final response = await _client.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.setAccessToken(accessToken);
      await TokenStorage.setRefreshToken(refreshToken);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Subscription paid successfully",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ApiErrorHandler.handleErrorResponse(response.body, context, null);
    }
  }
}
