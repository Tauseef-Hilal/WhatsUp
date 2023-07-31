import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnreadMessagesBanner extends ConsumerWidget {
  const UnreadMessagesBanner({
    super.key,
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    String text = '$unreadCount Unread Message';
    if (unreadCount > 1) {
      text += 's';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? const Color.fromARGB(100, 24, 34, 40)
            : const Color.fromARGB(100, 233, 232, 232),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? const Color.fromARGB(255, 29, 42, 49)
                : const Color.fromARGB(255, 233, 232, 232),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
