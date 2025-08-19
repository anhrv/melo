import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/models/user_response.dart';
import 'package:melo_desktop/models/paged_response.dart';
import 'package:melo_desktop/pages/admin_user_add_page.dart';
import 'package:melo_desktop/pages/admin_user_edit_page.dart';
import 'package:melo_desktop/services/role_service.dart';
import 'package:melo_desktop/services/user_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/toast_util.dart';
import 'package:melo_desktop/widgets/admin_side_menu.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';

class AdminUserSearchPage extends StatefulWidget {
  const AdminUserSearchPage({super.key});

  @override
  State<AdminUserSearchPage> createState() => _AdminUserSearchPageState();
}

class _AdminUserSearchPageState extends State<AdminUserSearchPage> {
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late Future<PagedResponse<UserResponse>?> _userFuture;
  late UserService _userService;
  late RoleService _roleService;

  bool _isFilterOpen = false;
  String? _selectedSortBy = 'createdAt';
  bool? _selectedSortOrder = false;

  bool? _isDeleted;
  bool? _isSubscribed;

  List<LovResponse> _selectedRoles = [];

  static const _sortOptions = {
    'createdAt': 'Created date',
    'modifiedAt': 'Updated date',
  };
  static const _orderOptions = {false: 'Descending', true: 'Ascending'};

  @override
  void initState() {
    super.initState();
    _userService = UserService(context);
    _roleService = RoleService(context);
    _userFuture = _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<PagedResponse<UserResponse>?> _fetchUsers() async {
    final username = _searchController.text.trim();
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final email = _emailController.text.trim();

    return _userService.get(
      context,
      page: _currentPage,
      username: username.isNotEmpty ? username : null,
      firstname: firstname.isNotEmpty ? firstname : null,
      lastname: lastname.isNotEmpty ? lastname : null,
      email: email.isNotEmpty ? email : null,
      roleIds: _selectedRoles.isNotEmpty
          ? _selectedRoles.map((r) => r.id).toList()
          : null,
      isDeleted: _isDeleted,
      isSubscribed: _isSubscribed,
      sortBy: _selectedSortBy,
      ascending: _selectedSortOrder,
    );
  }

  void _performSearch() {
    setState(() {
      _currentPage = 1;
      _userFuture = _fetchUsers();
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _userFuture = _fetchUsers();
    });
  }

  void _handleRoleSelection(List<LovResponse> selected) {
    setState(() => _selectedRoles = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Users"),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isFilterOpen) {
                setState(() => _isFilterOpen = false);
              }
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      _buildSearchBar(),
                      const SizedBox(
                        height: 4,
                      ),
                      FutureBuilder<PagedResponse<UserResponse>?>(
                        future: _userFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height:
                                  constraints.maxHeight - kToolbarHeight * 2,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return SizedBox(
                              height:
                                  constraints.maxHeight - kToolbarHeight * 2,
                              child: Center(
                                  child: Text('Error: ${snapshot.error}')),
                            );
                          }
                          final data = snapshot.data;
                          if (data == null || data.data.isEmpty) {
                            return SizedBox(
                              height:
                                  constraints.maxHeight - kToolbarHeight * 2,
                              child: const Center(
                                  child: Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 12,
                                    left: 24,
                                  ),
                                  child: Text(
                                    '${data.items} of ${data.totalItems}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              _buildUserList(data.data),
                              _buildPagination(data),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isFilterOpen)
            ModalBarrier(
              dismissible: true,
              color: Colors.black.withOpacity(0.4),
              onDismiss: () => setState(() => _isFilterOpen = false),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isFilterOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _buildFilterPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1750),
      child: Container(
        height: kToolbarHeight * 1.0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.filter_alt),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isFilterOpen = !_isFilterOpen;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 60,
              child: SizedBox(
                height: kToolbarHeight * 0.9,
                child: TextField(
                  controller: _searchController,
                  cursorColor: AppColors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search by username',
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.add),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminSideMenuScaffold(
                            body: AdminUserAddPage(), selectedIndex: 4)),
                  ).then((result) {
                    ToastUtil.showToast(
                        'User created successfully', false, context);
                    setState(() {
                      _currentPage = 1;
                      _userFuture = _fetchUsers();
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserResponse> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final roles = user.roles.map((r) => r.name);
        final rolesDisplay = roles.join(', ');

        final String firstName =
            user.firstName != null && user.firstName!.isNotEmpty
                ? "${user.firstName} "
                : "";
        final String lastName =
            user.lastName != null && user.lastName!.isNotEmpty
                ? user.lastName!
                : "";
        final fullName = firstName + lastName;

        return Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.grey,
                width: 0.1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.1),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    user.userName ?? 'No username',
                    style: TextStyle(
                        color: user.deleted != null && user.deleted!
                            ? AppColors.redAccent
                            : AppColors.white70,
                        fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              subtitle: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.email ?? 'No email',
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fullName.isNotEmpty ? fullName : "No full name",
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      rolesDisplay,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: PopupMenuButton<String>(
                  elevation: 0,
                  color: AppColors.backgroundLighter2,
                  surfaceTintColor: Colors.white,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert),
                  tooltip: "",
                  enabled: user.deleted != null && !user.deleted!,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminSideMenuScaffold(
                                body: AdminUserEditPage(
                                  userId: user.id,
                                  initialEditMode: true,
                                ),
                                selectedIndex: 4)),
                      ).then((_) {
                        setState(() {
                          _userFuture = _fetchUsers();
                        });
                      });
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 0.0),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 20,
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
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 400),
                            child: const Text(
                              'Are you sure you want to delete this user? This action is permanent.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          backgroundColor: AppColors.backgroundLighter2,
                          surfaceTintColor: Colors.transparent,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.white,
                                  )),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Yes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.white,
                                  )),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        final success =
                            await _userService.delete(user.id, context);
                        if (success) {
                          ToastUtil.showToast(
                              "User deleted successfully", false, context);
                          setState(() {
                            _userFuture = _fetchUsers();
                          });
                        }
                      }
                    }
                  },
                ),
              ),
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 0,
                top: 8,
                bottom: 8,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminSideMenuScaffold(
                        body: AdminUserEditPage(userId: user.id),
                        selectedIndex: 3),
                  ),
                ).then((_) {
                  setState(() {
                    _userFuture = _fetchUsers();
                  });
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(PagedResponse<UserResponse> data) {
    const int maxVisiblePages = 3;
    final int current = data.page;
    final int total = data.totalPages;

    List<int?> pages = [];
    if (total <= maxVisiblePages + 2) {
      pages = List.generate(total, (i) => i + 1);
    } else {
      int start = current - (maxVisiblePages ~/ 2);
      int end = current + (maxVisiblePages ~/ 2);

      if (start < 1) {
        start = 1;
        end = maxVisiblePages;
      }
      if (end > total) {
        end = total;
        start = max(1, end - maxVisiblePages + 1);
      }

      if (start > 1) pages.add(1);
      if (start > 2) pages.add(null);

      for (int i = start; i <= end; i++) {
        pages.add(i);
      }

      if (end < total - 1) pages.add(null);
      if (end < total) pages.add(total);
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                data.prevPage != null ? () => _loadPage(data.prevPage!) : null,
          ),
          const SizedBox(width: 6),
          Row(
            children: pages.map((page) {
              if (page == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text('...', style: TextStyle(color: AppColors.grey)),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => _loadPage(page),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: page == current
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: page == current
                            ? Colors.white
                            : AppColors.secondary,
                        fontWeight: page == current
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                data.nextPage != null ? () => _loadPage(data.nextPage!) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(width: 1),
    );

    return Container(
      width: 280,
      color: AppColors.white,
      child: Material(
        elevation: 16,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 4.0,
                      ),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _isFilterOpen = false),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'First name',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstnameController,
                  cursorColor: AppColors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'First name',
                    hintStyle: const TextStyle(fontSize: 14),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Last name',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastnameController,
                  cursorColor: AppColors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Last name',
                    hintStyle: const TextStyle(fontSize: 14),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  cursorColor: AppColors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(fontSize: 14),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Text(
                        'Roles',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedRoles.map((role) {
                            return Container(
                              padding: EdgeInsets.only(
                                top: 8,
                              ),
                              child: Chip(
                                label: Text(role.name),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                deleteIconColor: AppColors.grey,
                                onDeleted: () =>
                                    setState(() => _selectedRoles.remove(role)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: AppColors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                backgroundColor: AppColors.background,
                                deleteButtonTooltipMessage: "",
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                size: 16,
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
                                    fontSize: 16,
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
                const SizedBox(height: 24),
                _buildToggleFilter(
                  title: 'Deleted',
                  value: _isDeleted,
                  onChanged: (val) => setState(() => _isDeleted = val),
                ),
                const SizedBox(height: 24),
                _buildToggleFilter(
                  title: 'Subscribed',
                  value: _isSubscribed,
                  onChanged: (val) => setState(() => _isSubscribed = val),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  dropdownColor: AppColors.backgroundLighter2,
                  elevation: 0,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1,
                        color: AppColors.white54,
                      ),
                    ),
                    focusedBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    filled: true,
                    isDense: true,
                  ),
                  value: _selectedSortBy,
                  onChanged: (value) => setState(() => _selectedSortBy = value),
                  items: _sortOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Sort order',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  dropdownColor: AppColors.backgroundLighter2,
                  elevation: 0,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1,
                        color: AppColors.white54,
                      ),
                    ),
                    focusedBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    filled: true,
                    isDense: true,
                  ),
                  value: _selectedSortOrder,
                  onChanged: (value) =>
                      setState(() => _selectedSortOrder = value),
                  items: _orderOptions.entries.map((entry) {
                    return DropdownMenuItem<bool>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _performSearch();
                      setState(() => _isFilterOpen = false);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleFilter({
    required String title,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2.0, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtons(
                isSelected: [
                  value == null,
                  value == true,
                  value == false,
                ],
                onPressed: (index) {
                  onChanged(index == 0 ? null : index == 1);
                },
                color: AppColors.white,
                selectedColor: AppColors.secondary,
                fillColor: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                borderWidth: 0.5,
                borderColor: AppColors.white70,
                selectedBorderColor: AppColors.white70,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Any'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Yes'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
