import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/colors.dart';

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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tabColor,
        foregroundColor: AppColors.blackColor,
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(text),
    );
  }
}
