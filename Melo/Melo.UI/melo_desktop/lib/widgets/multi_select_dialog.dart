import 'package:flutter/material.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/themes/app_colors.dart';

class MultiSelectDialog extends StatefulWidget {
  final Future<List<LovResponse>> Function(String?) fetchOptions;
  final List<LovResponse> selected;
  final Widget? addOptionPage;
  final Future<void> Function(List<LovResponse>, BuildContext)? onConfirm;

  const MultiSelectDialog({
    super.key,
    required this.fetchOptions,
    required this.selected,
    this.addOptionPage,
    this.onConfirm,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<LovResponse> _tempSelected;
  List<LovResponse> _options = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selected);
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => _isLoading = true);
    try {
      final options = await widget.fetchOptions(
          _searchController.text.isEmpty ? null : _searchController.text);
      setState(() => _options = options);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 0.0),
            child: Text(
              'Select',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
              ),
            ),
          ),
          IconButton(
            iconSize: 22,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.white70,
                          size: 20,
                        ),
                        onPressed: _loadOptions,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                    ),
                    onSubmitted: (_) => _loadOptions(),
                  ),
                ),
                if (widget.addOptionPage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.white70,
                        size: 28,
                      ),
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => widget.addOptionPage!),
                        ).then(
                          (_) {
                            _loadOptions();
                          },
                        ),
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _options.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('No items found'),
                        )
                      : ListView.builder(
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final option = _options[index];
                            return CheckboxListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 8.0, right: 4.0),
                              title: Text(
                                option.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              activeColor: AppColors.secondary,
                              value: _tempSelected.contains(option),
                              onChanged: (checked) => setState(() {
                                if (checked!) {
                                  _tempSelected.add(option);
                                } else {
                                  _tempSelected.remove(option);
                                }
                              }),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.onConfirm != null) {
              widget.onConfirm!(_tempSelected, context);
              Navigator.pop(context);
            } else {
              Navigator.pop(context, _tempSelected);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
