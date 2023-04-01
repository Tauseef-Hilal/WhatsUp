import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

enum SnacBarType { error, info }

const snackBarBuilders = {
  SnacBarType.error: _errorSnackBar,
  SnacBarType.info: _infoSnackBar,
};

SnackBar _errorSnackBar(BuildContext context, String content) {
  return SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).custom.colorTheme.errorSnackBarColor);
}

SnackBar _infoSnackBar(BuildContext context, String content) {
  return SnackBar(
    content: Text(
      content,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Theme.of(context).custom.colorTheme.greenColor,
  );
}

void showSnackBar({
  required BuildContext context,
  required String content,
  required SnacBarType type,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    snackBarBuilders[type]!(context, content),
  );
}
