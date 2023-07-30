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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(transparency ? 160 : 230, 13, 13, 16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 24,
      ),
      child: Text(
        date,
        style: TextStyle(
          color: Theme.of(context).custom.colorTheme.iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}