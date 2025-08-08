import 'package:flutter/material.dart';
import '../../core/date_formatter.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- MODIFIED: The widget is now styled using the ChipTheme for consistency ---
    return Chip(
      label: Text(
        formatDisplayDate(date),
        style: TextStyle(
          // Use the chip's label style for the text color
          color: theme.chipTheme.labelStyle?.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      // The background color comes from the theme
      backgroundColor: theme.chipTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      shape: theme.chipTheme.shape,
    );
  }
}