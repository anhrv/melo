import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/models/user_response.dart';
import 'package:melo_desktop/pages/change_password_page.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/services/auth_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/toast_util.dart';
import 'package:melo_desktop/widgets/admin_side_menu.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  bool _isLoading = false;
  bool _isEdited = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  Map<String, String> _fieldErrors = {};
  late UserResponse? _initialUserData;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _initialUserData = userProvider.user;

    _firstNameController =
        TextEditingController(text: _initialUserData?.firstName);
    _lastNameController =
        TextEditingController(text: _initialUserData?.lastName);
    _usernameController =
        TextEditingController(text: _initialUserData?.userName);
    _emailController = TextEditingController(text: _initialUserData?.email);

    _firstNameController.addListener(_checkForChanges);
    _lastNameController.addListener(_checkForChanges);
    _usernameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool mapsEqual(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void _checkForChanges() {
    final currentState = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'userName': _usernameController.text,
      'email': _emailController.text,
    };

    final initialState = {
      'firstName': _initialUserData?.firstName,
      'lastName': _initialUserData?.lastName,
      'userName': _initialUserData?.userName,
      'email': _initialUserData?.email,
    };

    setState(() => _isEdited = !mapsEqual(currentState, initialState));
  }

  void _saveChanges() async {
    if (_isLoading || !_isEdited) return;
    setState(() {
      _fieldErrors = {};
    });
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final updatedUser = await _authService.updateAccount(
        _firstNameController.text,
        _lastNameController.text,
        _usernameController.text,
        _emailController.text.trim(),
        (errors) => setState(() => _fieldErrors = errors),
        context,
      );

      if (updatedUser != null && mounted) {
        final user = UserResponse.fromJson(updatedUser);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(user);
        _initialUserData = userProvider.user;
        _checkForChanges();

        ToastUtil.showToast("Changes saved successfully", false, context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToChangePassword() async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    // );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSideMenuScaffold(
          body: const ChangePasswordPage(),
          selectedIndex: -1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Edit account",
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  // First Name and Last Name Inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First name',
                            errorText: _fieldErrors['FirstName'],
                          ),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            errorText: _fieldErrors['LastName'],
                          ),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Username Input
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: _fieldErrors['UserName'],
                    ),
                    style: TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _fieldErrors['Email'],
                    ),
                    style: TextStyle(fontSize: 18),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Value is not a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  // Change password navigation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isEdited ? _saveChanges : null,
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Change password",
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 18,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _navigateToChangePassword,
                          ),
                        ),
                      ],
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
