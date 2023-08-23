import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import 'custom_progress.dart';

class ProgressCancelBtn extends StatelessWidget {
  const ProgressCancelBtn({
    super.key,
    required this.onTap,
    this.overlayColor,
    this.progressValue,
  });

  final VoidCallback onTap;
  final double? progressValue;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: overlayColor,
              shape: BoxShape.circle,
            ),
            child: progressValue != null
                ? CustomProgressIndicator(
                    value: progressValue!,
                    trackColor: const Color.fromARGB(18, 0, 0, 0),
                    progressColor:
                        Theme.of(context).custom.colorTheme.greenColor,
                    strokeWidth: 3.0,
                  )
                : CircularProgressIndicator(
                    backgroundColor: const Color.fromARGB(18, 0, 0, 0),
                    color: Theme.of(context).custom.colorTheme.greenColor,
                    strokeWidth: 3.0,
                  ),
          ),
          Icon(
            Platform.isAndroid ? Icons.close_rounded : Icons.stop_rounded,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
