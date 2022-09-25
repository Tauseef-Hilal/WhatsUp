import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/colors.dart';

// THEME PROVIDERS
final darkThemeProvider = Provider((ref) => _darkTheme);
final lightThemeProvider = Provider((ref) => _theme);

// THEMES
// Light theme (Not implemented yet)
final _theme = ThemeData(brightness: Brightness.light);
final _customTheme = CustomThemeData();

// Dark theme
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    backgroundColor: AppColors.appBarColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColors.appBarColor,
      systemNavigationBarColor: AppColors.backgroundColor,
      systemNavigationBarDividerColor: AppColors.backgroundColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.greenColor,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.backgroundColor,
  iconTheme: const IconThemeData(
    color: AppColors.iconColor,
  ),
);

final _customDarkTheme = CustomThemeData();

// EXTENSIONS AND CLASSES
class CustomTextTheme {
  final titleLarge = const TextStyle(
    fontSize: 18,
    color: AppColors.greyColor,
  );
  final titleMedium = const TextStyle(
    fontSize: 16,
    color: AppColors.textColor1,
  );
  final labelLarge = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.greyColor,
  );
  final subtitle1 = const TextStyle(
    fontSize: 15,
    color: AppColors.greyColor,
  );
  final subtitle2 = const TextStyle(
    fontSize: 14,
    color: AppColors.greyColor,
  );
  final bodyText1 = const TextStyle(fontSize: 16);
  final caption = const TextStyle(
    color: AppColors.greyColor,
    fontSize: 12,
  );
  final bold = const TextStyle(fontWeight: FontWeight.w500);
}

class CustomThemeData {
  final textTheme = CustomTextTheme();
}

extension CustomTheme on ThemeData {
  CustomThemeData get custom =>
      brightness == Brightness.dark ? _customDarkTheme : _customTheme;

  AssetImage themedImage(String name) {
    final path =
        brightness == Brightness.dark ? 'assets/images/dark' : 'assets/images';
    return AssetImage('$path/$name');
  }
}
