import "dart:convert";

import "package:fpdart/fpdart.dart";
import "package:http/http.dart" as http;
import "package:melo_mobile/core/constants/api_constants.dart";
import "package:melo_mobile/core/error/error_response.dart";
import "package:melo_mobile/features/auth/model/token_response.dart";

class AuthRemoteRepository {
  Future<Either<ErrorResponse, TokenResponse>> register({
    required String userName,
    required String email,
    required String passwordInput,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userName': userName,
          'email': email,
          'passwordInput': passwordInput,
          'passwordConfirm': passwordConfirm,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone
        }),
      );

      if (response.statusCode != 201) {
        return Left(ErrorResponse.fromJson(response.body));
      }
      return Right(TokenResponse.fromJson(response.body));
    } catch (e) {
      return Left(ErrorResponse.customErrorReponse(message: e.toString()));
    }
  }

  Future<Either<ErrorResponse, TokenResponse>> login({
    required String emailUsername,
    required String passwordInput,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailUsername': emailUsername,
          'passwordInput': passwordInput,
        }),
      );
      if (response.statusCode != 200) {
        return Left(ErrorResponse.fromJson(response.body));
      }
      return Right(TokenResponse.fromJson(response.body));
    } catch (e) {
      return Left(ErrorResponse.customErrorReponse(message: e.toString()));
    }
  }
}
