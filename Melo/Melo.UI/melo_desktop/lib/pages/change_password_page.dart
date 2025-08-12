import 'package:flutter/material.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();
  late AuthService _authService;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
  }

  void _changePassword() async {
    if (_isLoading) return;

    setState(() {
      _fieldErrors = {};
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
        _newPasswordConfirmController.text,
        (errors) => setState(() => _fieldErrors = errors),
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
        appBar: CustomAppBar(title: "Change password"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Username Input
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      errorText: _fieldErrors['CurrentPassword'],
                    ),
                    style: TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // New Password Input
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      errorText: _fieldErrors['NewPassword'],
                    ),
                    style: TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _newPasswordConfirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      errorText: _fieldErrors['NewPasswordConfirm'],
                    ),
                    style: TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password confirmation is required';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  // Change password Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        child: const Text('Save'),
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
