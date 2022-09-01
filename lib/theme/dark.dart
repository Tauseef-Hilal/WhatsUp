import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/colors.dart';

ThemeData defaultDark = ThemeData.dark();
ThemeData darkTheme = defaultDark.copyWith(
  appBarTheme: defaultDark.appBarTheme.copyWith(
    elevation: 0.0,
    backgroundColor: AppColors.appBarColor,
  ),
  scaffoldBackgroundColor: AppColors.backgroundColor,
);
