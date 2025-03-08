import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String server = 'http://10.0.2.2:7286';
  static final String baseUrl = '$server/api';
  static final String login = '$baseUrl/auth/login';
  static final String register = '$baseUrl/auth/register';
  static final String refreshToken = '$baseUrl/auth/refresh-token';
  static final String createCheckoutSession =
      '$baseUrl/subscription/create-checkout-session';
  static final String confirmSubscription =
      '$baseUrl/subscription/confirm-subscription';
  static final String genre = '$baseUrl/genre';
}
