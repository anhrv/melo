import 'package:flutter/material.dart';
import 'package:melo_mobile/core/theme/app_colors.dart';
import 'package:melo_mobile/features/auth/view/pages/login_page.dart';
import 'package:melo_mobile/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melo_mobile/features/auth/view/widgets/custom_field.dart';
import 'package:melo_mobile/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordInputController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordInputController.dispose();
    passwordConfirmController.dispose();
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
              const Text('Register',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
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
                controller: userNameController,
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
                height: 10,
              ),
              CustomField(
                hintText: 'Confirm password',
                controller: passwordConfirmController,
                isObscureText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthGradientButton(
                buttonText: 'Register',
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await ref.read(authViewModelProvider.notifier).registerUser(
                        userName: userNameController.text,
                        email: emailController.text,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        passwordInput: passwordInputController.text,
                        passwordConfirm: passwordConfirmController.text,
                        phone: phoneController.text);
                  }
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
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16),
                    text: 'Already have an account? ',
                    children: [
                      TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                              color: AppColors.gradient2,
                              fontWeight: FontWeight.bold)),
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
