import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_clone/theme/colors.dart';

ThemeData defaultDark = ThemeData.dark();
ThemeData darkTheme = defaultDark.copyWith(
  appBarTheme: defaultDark.appBarTheme.copyWith(
    elevation: 0.0,
    backgroundColor: AppColors.appBarColor,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: AppColors.appBarColor,
      systemNavigationBarColor: AppColors.backgroundColor,
      systemNavigationBarDividerColor: AppColors.backgroundColor,
    ),
  ),
  floatingActionButtonTheme: defaultDark.floatingActionButtonTheme.copyWith(
    backgroundColor: AppColors.tabColor,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundColor,
);
