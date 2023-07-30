import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ChatDate extends StatelessWidget {
  const ChatDate({
    super.key,
    required this.date,
    this.transparency = false,
  });

  final String date;
  final bool transparency;

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkTheme
            ? const Color.fromARGB(255, 24, 34, 40)
            : const Color.fromARGB(255, 233, 232, 232),
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
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
