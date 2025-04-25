import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/services/user_service.dart';
import 'package:melo_mobile/services/role_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/utils/datetime_util.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminUserEditPage extends StatefulWidget {
  final int userId;
  final bool initialEditMode;

  const AdminUserEditPage({
    super.key,
    required this.userId,
    this.initialEditMode = false,
  });

  @override
  State<AdminUserEditPage> createState() => _AdminUserEditPageState();
}

class _AdminUserEditPageState extends State<AdminUserEditPage> {
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
  List<LovResponse> _originalRoles = [];

  String? originalUsername;
  String? originalFirstname;
  String? originalLastname;
  String? originalEmail;

  bool? isSubscribed;
  DateTime? subscriptionStart;
  DateTime? subscriptionEnd;

  bool _isDeleted = true;
  bool _isAdmin = true;
  bool _isEditMode = false;

  String? _roleError;

  @override
  void initState() {
    super.initState();
    _userService = UserService(context);
    _roleService = RoleService(context);
    _isEditMode = widget.initialEditMode;
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);
    final user = await _userService.getById(widget.userId, context);
    if (user != null) {
      setState(() {
        originalUsername = user.userName ?? "";
        originalFirstname = user.firstName ?? "";
        originalLastname = user.lastName ?? "";
        originalEmail = user.email ?? "";
        _selectedRoles =
            user.roles.map((g) => LovResponse(id: g.id, name: g.name)).toList();
        _isDeleted = user.deleted ?? false;
        isSubscribed = user.subscribed;
        subscriptionStart = user.subscriptionStart;
        subscriptionEnd = user.subscriptionEnd;
        _originalRoles = List.from(_selectedRoles);
        _usernameController.text = originalUsername ?? "";
        _firstnameController.text = originalFirstname ?? "";
        _lastnameController.text = originalLastname ?? "";
        _emailController.text = originalEmail ?? "";
        _isAdmin = _originalRoles.any((role) => role.name == "Admin");
      });
    }
    setState(() => _isLoading = false);
  }

  void _cancelEdit() {
    _formKey.currentState?.reset();
    setState(() {
      _isEditMode = false;
      _usernameController.text = originalUsername ?? "";
      _firstnameController.text = originalFirstname ?? "";
      _lastnameController.text = originalLastname ?? "";
      _emailController.text = originalEmail ?? "";
      _passwordController.text = "";
      _confirmPasswordController.text = "";
      _fieldErrors = {};
      _roleError = null;
      _selectedRoles = _originalRoles.toList();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _formKey.currentState?.validate();
      }
    });
  }

  bool get _hasChanges {
    final usernameChanged = _usernameController.text != originalUsername;
    final firstnameChanged = _firstnameController.text != originalFirstname;
    final lastnameChanged = _lastnameController.text != originalLastname;
    final emailChanged = _emailController.text != originalEmail;
    final passwordChanged =
        _passwordController.text != "" || _confirmPasswordController.text != "";
    final rolesChanged = !const SetEquality()
        .equals(_selectedRoles.toSet(), _originalRoles.toSet());
    return usernameChanged ||
        firstnameChanged ||
        lastnameChanged ||
        emailChanged ||
        passwordChanged ||
        rolesChanged;
  }

  Future<void> _saveChanges() async {
    if (_isLoading || !_hasChanges) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _roleError = null;
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final newUsername = _usernameController.text;
      final newFirstname = _firstnameController.text;
      final newLastname = _lastnameController.text;
      final newEmail = _emailController.text;
      final newPassword = _passwordController.text;
      final newConfirmPassword = _confirmPasswordController.text;

      bool usernameChanged = newUsername != originalUsername;
      bool firstnameChanged = newFirstname != originalFirstname;
      bool lastnameChanged = newLastname != originalLastname;
      bool emailChanged = newEmail != originalEmail;
      bool rolesChanged = !const SetEquality()
          .equals(_selectedRoles.toSet(), _originalRoles.toSet());
      bool passwordChange = newPassword != "" && newConfirmPassword != "";

      if (usernameChanged ||
          firstnameChanged ||
          lastnameChanged ||
          emailChanged ||
          passwordChange ||
          rolesChanged) {
        final updated = await _userService.update(
          widget.userId,
          newUsername,
          newFirstname,
          newLastname,
          newEmail,
          newPassword,
          newConfirmPassword,
          _selectedRoles.isNotEmpty
              ? _selectedRoles.map((g) => g.id).toList()
              : null,
          context,
          (errors) => setState(() => _fieldErrors = errors),
        );
        if (updated == null) return;
        originalUsername = newUsername;
        originalFirstname = newFirstname;
        originalLastname = newLastname;
        originalEmail = newEmail;
        _originalRoles = _selectedRoles.toList();
      }

      await _fetchUser();
      _cancelEdit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User updated successfully',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Text(
                'Delete user',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.redAccent,
                ),
              ),
            ),
            IconButton(
              iconSize: 22,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this user? This action is permanent.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                )),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final success = await _userService.delete(widget.userId, context);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User deleted successfully",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  void _handleRoleSelection(List<LovResponse> selected) {
    if (selected.isEmpty) {
      setState(() {
        _roleError = "User has to have at least one role";
      });
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
        appBar: const CustomAppBar(title: "User details"),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
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
                        readOnly: !_isEditMode,
                        onChanged: (value) {
                          if (_isEditMode) {
                            setState(() {});
                          }
                        },
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
                        readOnly: !_isEditMode,
                        onChanged: (value) {
                          if (_isEditMode) {
                            setState(() {});
                          }
                        },
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
                  readOnly: !_isEditMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_isEditMode) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _fieldErrors['Email'],
                  ),
                  readOnly: !_isEditMode,
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
                  onChanged: (value) {
                    if (_isEditMode) {
                      setState(() {});
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Roles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _selectedRoles.isEmpty && !_isEditMode
                            ? const Text("No roles")
                            : Wrap(
                                spacing: 8,
                                children: _selectedRoles.map((role) {
                                  return Chip(
                                    label: Text(role.name),
                                    deleteIcon:
                                        _isEditMode && _selectedRoles.length > 1
                                            ? const Icon(Icons.close, size: 18)
                                            : null,
                                    onDeleted: _isEditMode &&
                                            _selectedRoles.length > 1
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
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        if (_isEditMode) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
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
                                          builder: (context) =>
                                              MultiSelectDialog(
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
                      ],
                    ),
                  ],
                ),
                if (_isEditMode) ...[
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      errorText: _fieldErrors['newPassword'],
                    ),
                    readOnly: !_isEditMode,
                    validator: (value) {
                      if (value != null && value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_isEditMode) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      errorText: _fieldErrors['PasswordConfirm'],
                    ),
                    readOnly: !_isEditMode,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_isEditMode) {
                        setState(() {});
                      }
                    },
                  ),
                ],
                if (!_isEditMode && !_isAdmin) ...[
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Subscribed: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white54,
                            ),
                          ),
                          if (isSubscribed != null)
                            Icon(
                              isSubscribed! ? Icons.check_circle : Icons.cancel,
                              color: isSubscribed!
                                  ? AppColors.greenAccent
                                  : AppColors.redAccent,
                              size: 20,
                            )
                          else
                            const Text(
                              'N/A',
                              style: TextStyle(
                                  color: AppColors.white70, fontSize: 15),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Subscription start: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white54,
                            ),
                          ),
                          Text(
                            subscriptionStart != null
                                ? DateTimeUtil.formatUtcToLocal(
                                    subscriptionStart.toString())
                                : 'N/A',
                            style: const TextStyle(
                                color: AppColors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Subscription end: ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white54,
                            ),
                          ),
                          Text(
                            subscriptionEnd != null
                                ? DateTimeUtil.formatUtcToLocal(
                                    subscriptionEnd.toString())
                                : 'N/A',
                            style: const TextStyle(
                                color: AppColors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
                const SizedBox(height: 40),
                if (!_isDeleted)
                  _isEditMode ? _buildEditButtons() : _buildViewButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isEditMode = true),
            child: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasChanges ? null : AppColors.grey.withOpacity(0.5),
            ),
            child: const Text('Save changes'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _cancelEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
