class ApiConstants {
  static const String server = 'http://10.0.2.2:7286';
  static const String baseUrl = '$server/api';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String createSubscription =
      '$baseUrl/subscription/create-subscription';
  static const String confirmSubscription =
      '$baseUrl/subscription/confirm-subscription';
  static const String genre = '$baseUrl/genre';
}
