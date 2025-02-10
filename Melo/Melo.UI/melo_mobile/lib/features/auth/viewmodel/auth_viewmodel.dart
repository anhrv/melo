import 'package:fpdart/fpdart.dart';
import 'package:melo_mobile/features/auth/model/token_response.dart';
import 'package:melo_mobile/features/auth/repositories/auth_remote_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  final AuthRemoteRepository _authRemoteRepository = AuthRemoteRepository();
  @override
  AsyncValue<TokenResponse>? build() {
    return null;
  }

  Future<void> registerUser({
    required String userName,
    required String email,
    required String passwordInput,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await _authRemoteRepository.register(
      userName: userName,
      email: email,
      passwordInput: passwordInput,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    final val = switch (response) {
      Left(value: final l) => l,
      Right(value: final r) => r,
    };

    print(val);
  }
}
