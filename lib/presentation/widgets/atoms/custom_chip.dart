import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onDeleted;

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(color: textColor ?? Colors.white)),
      backgroundColor: color ?? Theme.of(context).primaryColor,
      deleteIcon: onDeleted != null
          ? Icon(Icons.close, size: 18, color: textColor ?? Colors.white)
          : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
