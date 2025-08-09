import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String server = dotenv.env['SERVER']!;
  static final String fileServer = dotenv.env['FILE_SERVER']!;
  static final String baseUrl = '$server/api';
  static final String login = '$baseUrl/auth/login-admin';
  static final String logout = '$baseUrl/auth/logout';
  static final String refreshToken = '$baseUrl/auth/refresh-token';
  static final String currentUser = '$baseUrl/auth/user';
  static final String changePassword = '$baseUrl/auth/user/password';
  static final String cancelSubscription =
      '$baseUrl/subscription/cancel-subscription';
  static final String song = '$baseUrl/song';
  static final String genre = '$baseUrl/genre';
  static final String artist = '$baseUrl/artist';
  static final String album = '$baseUrl/album';
  static final String user = '$baseUrl/user';
  static final String role = '$baseUrl/role';
  static final String trainModels = '$baseUrl/recommendations/train-models';
}
