import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melo_desktop/pages/admin_pdf_preview_page.dart';
import 'package:melo_desktop/services/analytics_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/admin_app_drawer.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/user_drawer.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  late AnalyticsService _analyticsService;

  bool _isLoading = false;
  String? _selectedEntity = "song";
  String? _selectedSortBy = "likeCount";
  bool? _selectedSortOrder = false;

  List<Map<String, dynamic>> _reportData = [];

  static const _entityOptions = {
    'song': 'Songs',
    'album': 'Albums',
    'artist': 'Artists',
    'genre': 'Genres',
  };

  static const _sortOptions = {'likeCount': 'Likes', 'viewCount': 'Views'};

  static const _orderOptions = {false: 'Descending', true: 'Ascending'};

  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService(context);
    _amountController.text = "10";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateReport() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await _analyticsService.get(
        context,
        amount: int.parse(_amountController.text),
        entity: _selectedEntity!,
        sortBy: _selectedSortBy!,
        ascending: _selectedSortOrder!,
      );

      if (response != null && response.isNotEmpty && mounted) {
        _reportData = List<Map<String, dynamic>>.from(response);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminPdfPreviewPage(
              data: _reportData,
              entity: _selectedEntity!,
              sortBy: _selectedSortBy!,
              ascending: _selectedSortOrder!,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No data to show',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(width: 1),
    );

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Analytics"),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Entities',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                  value: _selectedEntity,
                  onChanged: (value) => setState(() => _selectedEntity = value),
                  items: _entityOptions.entries.map((entry) {
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
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                      errorBorder: inputBorder.copyWith(
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: AppColors.error,
                        ),
                      ),
                      focusedErrorBorder: inputBorder.copyWith(
                        borderSide: const BorderSide(
                          width: 1.5,
                          color: AppColors.error,
                        ),
                      ),
                      errorStyle: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                    value: _selectedSortBy,
                    onChanged: (value) =>
                        setState(() => _selectedSortBy = value),
                    items: _sortOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == 'likeCount' && _selectedEntity == 'genre') {
                        return 'Genres can only be sorted by view count';
                      }
                      return null;
                    }),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Sort order',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    errorBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.error,
                      ),
                    ),
                    focusedErrorBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        width: 1.5,
                        color: AppColors.error,
                      ),
                    ),
                    filled: true,
                    isDense: true,
                    hintText: '1-100',
                    errorStyle: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    final number = int.tryParse(value);
                    if (number == null) {
                      return 'Amount must be a valid number';
                    }
                    if (number < 1 || number > 100) {
                      return 'Amount must be between 1 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateReport,
                    child: const Text('Generate report'),
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
