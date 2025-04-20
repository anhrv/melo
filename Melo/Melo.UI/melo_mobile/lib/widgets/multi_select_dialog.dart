import 'package:flutter/material.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<LovResponse> options;
  final List<int> selected;

  const MultiSelectDialog({
    super.key,
    required this.options,
    required this.selected,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        'Select',
        style: TextStyle(
          fontSize: 18,
          color: AppColors.secondary,
        ),
      ),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            return CheckboxListTile(
              title: Text(option.name),
              activeColor: AppColors.secondary,
              value: _tempSelected.contains(option.id),
              onChanged: (checked) => setState(() {
                if (checked!) {
                  _tempSelected.add(option.id);
                } else {
                  _tempSelected.remove(option.id);
                }
              }),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
