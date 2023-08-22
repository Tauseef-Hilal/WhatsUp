import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class GreenElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GreenElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Theme.of(context).custom.colorTheme.greenColor,
        foregroundColor: Theme.of(context).custom.colorTheme.backgroundColor,
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(text),
    );
  }
}
