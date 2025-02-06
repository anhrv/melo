import 'package:flutter/material.dart';
import 'package:melo_mobile/core/theme/app_colors.dart';
import 'package:melo_mobile/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melo_mobile/features/auth/view/widgets/custom_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  const Text('Sign Up',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomField(
                          hintText: 'First name',
                          controller: firstNameController,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomField(
                          hintText: 'Last name',
                          controller: lastNameController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomField(
                    hintText: 'Phone',
                    controller: phoneController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomField(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomField(
                    hintText: 'Username',
                    controller: usernameController,
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
                    height: 10,
                  ),
                  CustomField(
                    hintText: 'Confirm password',
                    controller: confirmPasswordController,
                    isObscureText: true,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AuthGradientButton(
                    buttonText: 'Sign Up',
                    onPressed: () {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16),
                      text: 'Already have an account? ',
                      children: [
                        TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                                color: AppColors.gradient2,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
