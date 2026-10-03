import 'package:flutter/material.dart';

class TopToast {
  static void show(BuildContext context, String message) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 120,
          left: 20,
          right: 20,
        ),
        elevation: 6,
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.up,
      ),
    );
  }
}
