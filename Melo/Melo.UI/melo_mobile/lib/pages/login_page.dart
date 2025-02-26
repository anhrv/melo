import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_mobile/pages/register_page.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  Map<String, String> _fieldErrors = {};

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String emailUsername = _emailUsernameController.text.trim();
    String passwordInput = _passwordController.text;

    try {
      await _authService.login(
        emailUsername,
        passwordInput,
        (errors) {
          setState(() {
            _fieldErrors = errors;
          });
        },
        context,
      );
      // TODO: Navigate to the next screen if needed.
    } catch (ex) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 24.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - (verticalPadding * 2),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Username/Email Input
                        TextFormField(
                          controller: _emailUsernameController,
                          decoration: InputDecoration(
                            labelText: 'Username or Email',
                            errorText: _fieldErrors['EmailUsername'],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username or Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: _fieldErrors['PasswordInput'],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 16),

                        // Register Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: 'Register here',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _authService.getData(
                                        context,
                                      );
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         const RegisterPage(),
                                      //   ),
                                      // );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
