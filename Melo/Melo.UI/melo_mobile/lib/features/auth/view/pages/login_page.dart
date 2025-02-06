import 'package:flutter/material.dart';
import 'package:melo_mobile/core/theme/app_colors.dart';
import 'package:melo_mobile/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melo_mobile/features/auth/view/widgets/custom_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameEmailController.dispose();
    passwordController.dispose();
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
              const Text('Sign In',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 15,
              ),
              CustomField(
                hintText: 'Username or email',
                controller: usernameEmailController,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomField(
                hintText: 'Password',
                controller: passwordController,
                isObscureText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthGradientButton(
                buttonText: 'Sign In',
                onPressed: () {},
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16),
                  text: 'Don\'t have an account? ',
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                          color: AppColors.gradient2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
