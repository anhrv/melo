import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/storage/token_storage.dart';

class AuthService {
  Future<void> login(String emailUsername, String passwordInput) async {
    final url = Uri.parse(ApiConstants.login);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'emailUsername': emailUsername,
        'passwordInput': passwordInput,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.setAccessToken(accessToken);
      await TokenStorage.setRefreshToken(refreshToken);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> getData() async {
    final url = Uri.parse(ApiConstants.genre);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await TokenStorage.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      print(
          "GET request failed. Status: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to fetch data');
    }
  }
}
