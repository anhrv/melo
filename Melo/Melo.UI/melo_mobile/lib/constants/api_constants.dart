import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String server = 'http://10.0.2.2:7286';
  static final String baseUrl = '$server/api';
  static final String login = '$baseUrl/auth/login';
  static final String genre = '$baseUrl/genre';
}
