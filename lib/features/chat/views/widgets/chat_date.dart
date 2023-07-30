import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ChatDate extends StatelessWidget {
  const ChatDate({
    super.key,
    required this.date,
    this.shouldBeTransparent = false,
  });

  final String date;
  final bool shouldBeTransparent;

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    int transparency = shouldBeTransparent ? 200 : 255;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkTheme
            ? Color.fromARGB(transparency, 24, 34, 40)
            : Color.fromARGB(transparency, 233, 232, 232),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 24,
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isDarkTheme
              ? Theme.of(context).custom.colorTheme.iconColor
              : Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
