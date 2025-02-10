import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:melo_mobile/core/theme/app_colors.dart';
import 'package:melo_mobile/features/auth/repositories/auth_remote_repository.dart';
import 'package:melo_mobile/features/auth/view/pages/register_page.dart';
import 'package:melo_mobile/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melo_mobile/features/auth/view/widgets/custom_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailUsernameController = TextEditingController();
  final passwordInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 15,
              ),
              CustomField(
                hintText: 'Username or email',
                controller: emailUsernameController,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomField(
                hintText: 'Password',
                controller: passwordInputController,
                isObscureText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthGradientButton(
                buttonText: 'Login',
                onPressed: () async {
                  final response = await AuthRemoteRepository().login(
                    emailUsername: emailUsernameController.text,
                    passwordInput: passwordInputController.text,
                  );

                  final val = switch (response) {
                    fpdart.Left(value: final l) => l,
                    fpdart.Right(value: final r) => r,
                  };

                  print(val);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16),
                    text: 'Don\'t have an account? ',
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                            color: AppColors.gradient2,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
