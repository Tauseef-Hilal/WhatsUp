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
      content: SizedBox(
        height: 90,
        child: child,
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: actions.first.value,
          child: Text(
            actions.first.key,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: actionButtonTextColor),
          ),
        ),
        TextButton(
          onPressed: actions.last.value,
          child: Text(
            actions.last.key,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: actionButtonTextColor),
          ),
        ),
      ],
    );
  }
}
