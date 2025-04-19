class ApiConstants {
  static const String server = 'http://10.0.2.2:7286';
  static const String fileServer = '10.0.2.2:7236';
  static const String baseUrl = '$server/api';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String currentUser = '$baseUrl/auth/user';
  static const String changePassword = '$baseUrl/auth/user/password';
  static const String createSubscription =
      '$baseUrl/subscription/create-subscription';
  static const String confirmSubscription =
      '$baseUrl/subscription/confirm-subscription';
  static const String cancelSubscription =
      '$baseUrl/subscription/cancel-subscription';
  static const String genre = '$baseUrl/genre';
  static const String artist = '$baseUrl/artist';
}
