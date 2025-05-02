// multi_select_dialog_field.dart
import 'package:flutter/material.dart';

class MultiSelectDialogField<T> extends StatelessWidget {
  final List<MultiSelectItem<T>> items;
  final String dialogTitle;
  final String buttonText;
  final Function(List<T>) onConfirm;

  const MultiSelectDialogField({
    required this.items,
    required this.dialogTitle,
    required this.buttonText,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showDialog(context),
      child: Text(buttonText),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => MultiSelectDialog<T>(
            title: dialogTitle,
            items: items,
            onConfirm: onConfirm,
          ),
    );
  }
}

class MultiSelectItem<T> {
  final T value;
  final String label;

  const MultiSelectItem(this.value, this.label);
}

class MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<MultiSelectItem<T>> items;
  final Function(List<T>) onConfirm;

  const MultiSelectDialog({
    required this.title,
    required this.items,
    required this.onConfirm,
    super.key,
  });

  @override
  State<MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  final List<T> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map(_buildCheckboxItem).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_selectedItems);
            Navigator.of(context).pop();
          },
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }

  Widget _buildCheckboxItem(MultiSelectItem<T> item) {
    return CheckboxListTile(
      title: Text(item.label),
      value: _selectedItems.contains(item.value),
      onChanged: (bool? isChecked) {
        setState(() {
          if (isChecked == true) {
            _selectedItems.add(item.value);
          } else {
            _selectedItems.remove(item.value);
          }
        });
      },
    );
  }
}
