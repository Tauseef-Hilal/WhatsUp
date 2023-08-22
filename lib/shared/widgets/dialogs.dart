import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final Color backgroundColor;
  final Color actionButtonTextColor;
  final Widget child;
  final Map<String, VoidCallback> actionCallbacks;

  const ConfirmationDialog({
    super.key,
    required this.backgroundColor,
    required this.child,
    required this.actionButtonTextColor,
    required this.actionCallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final actions = actionCallbacks.entries.toList();
    return AlertDialog(
      backgroundColor: backgroundColor,
      content: child,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: actions.first.value,
          child: Text(
            actions.first.key,
            style: TextStyle(color: actionButtonTextColor),
          ),
        ),
        TextButton(
          onPressed: actions.last.value,
          child: Text(
            actions.last.key,
            style: TextStyle(color: actionButtonTextColor),
          ),
        ),
      ],
    );
  }
}
