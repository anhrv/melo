import 'package:flutter/material.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService _authService;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
  }

  void _login() async {
    if (_isLoading) return;

    setState(() {
      _fieldErrors = {};
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      String emailUsername = _emailUsernameController.text.trim();
      String passwordInput = _passwordController.text;
      await _authService.login(
        emailUsername,
        passwordInput,
        (errors) {
          if (mounted) {
            setState(() => _fieldErrors = errors);
          }
        },
        context,
      );
    } catch (ex) {
      //
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username/Email Input
                  TextFormField(
                    controller: _emailUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Username or email',
                      border: const OutlineInputBorder(),
                      errorText: _fieldErrors['EmailUsername'],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username or email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      errorText: _fieldErrors['PasswordInput'],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
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
  }
}
