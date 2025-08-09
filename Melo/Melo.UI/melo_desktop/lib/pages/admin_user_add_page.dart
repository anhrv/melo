import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/services/user_service.dart';
import 'package:melo_desktop/services/role_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/admin_app_drawer.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';
import 'package:melo_desktop/widgets/user_drawer.dart';

class AdminUserAddPage extends StatefulWidget {
  const AdminUserAddPage({super.key});

  @override
  State<AdminUserAddPage> createState() => _AdminUserAddPageState();
}

class _AdminUserAddPageState extends State<AdminUserAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late UserService _userService;
  late RoleService _roleService;
  List<LovResponse> _selectedRoles = [];
  String? _roleError;

  @override
  void initState() {
    super.initState();
    _userService = UserService(context);
    _roleService = RoleService(context);
  }

  Future<void> _addUser() async {
    if (_isLoading) return;
    setState(() {
      _fieldErrors = {};
      _roleError = null;
    });
    if (_selectedRoles.isEmpty) {
      setState(() {
        _roleError = "User has to have at least one role";
      });
    }
    if (!_formKey.currentState!.validate()) return;
    if (_roleError != null) return;

    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final user = await _userService.create(
        _usernameController.text,
        _firstnameController.text,
        _lastnameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        _selectedRoles.map((g) => g.id).toList(),
        context,
        (errors) => setState(() => _fieldErrors = errors),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User created successfully',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRoleSelection(List<LovResponse> selected) {
    if (selected.isEmpty) {
      setState(() => _roleError = "User must have at least one role");
      return;
    }
    setState(() {
      _roleError = null;
      _selectedRoles = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Add user"),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          labelText: 'First name',
                          errorText: _fieldErrors['FirstName'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          labelText: 'Last name',
                          errorText: _fieldErrors['LastName'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: _fieldErrors['UserName'],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _fieldErrors['Email'],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Roles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedRoles.map((role) {
                            return Chip(
                              label: Text(role.name),
                              deleteIcon: _selectedRoles.length > 1
                                  ? const Icon(Icons.close, size: 18)
                                  : null,
                              onDeleted: _selectedRoles.length > 1
                                  ? () => setState(
                                      () => _selectedRoles.remove(role))
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.white70,
                                  width: 0.5,
                                ),
                              ),
                              backgroundColor: AppColors.background,
                              deleteIconColor: AppColors.grey,
                            );
                          }).toList(),
                        ),
                        if (_roleError != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _roleError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              RichText(
                                text: TextSpan(
                                  text: "Select roles",
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 14,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final selected =
                                          await showDialog<List<LovResponse>>(
                                        context: context,
                                        builder: (context) => MultiSelectDialog(
                                          fetchOptions: (searchTerm) =>
                                              _roleService.getLov(context,
                                                  name: searchTerm),
                                          selected: _selectedRoles,
                                        ),
                                      );
                                      if (selected != null) {
                                        _handleRoleSelection(selected);
                                      }
                                    },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _fieldErrors['newPassword'],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    errorText: _fieldErrors['PasswordConfirm'],
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
