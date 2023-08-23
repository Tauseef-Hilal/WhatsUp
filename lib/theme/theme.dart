import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/text_theme.dart';

class CustomThemeData {
  final textTheme = CustomTextTheme();
  late final ColorTheme colorTheme;

  CustomThemeData({required bool isDarkTheme}) {
    colorTheme = isDarkTheme
        ? ColorTheme(
            iconColor: AppColorsDark.iconColor,
            textColor1: AppColorsDark.textColor1,
            textColor2: AppColorsDark.textColor2,
            appBarColor: AppColorsDark.appBarColor,
            dividerColor: AppColorsDark.dividerColor,
            backgroundColor: AppColorsDark.backgroundColor,
            errorSnackBarColor: AppColorsDark.errorSnackBarColor,
            incomingMessageBubbleColor:
                AppColorsDark.incomingMessageBubbleColor,
            outgoingMessageBubbleColor:
                AppColorsDark.outgoingMessageBubbleColor,
            incomingEmbedColor: AppColorsDark.incomingEmbedColor,
            outgoingEmbedColor: AppColorsDark.outgoingEmbedColor,
            selectedLabelColor: AppColorsDark.selectedLabelColor,
            unselectedLabelColor: AppColorsDark.unselectedLabelColor,
            indicatorColor: AppColorsDark.indicatorColor,
            blueColor: AppColorsDark.blueColor,
            greenColor: AppColorsDark.greenColor,
            yellowColor: AppColorsDark.yellowColor,
            greyColor: AppColorsDark.greyColor,
            statusBarColor: AppColorsDark.statusBarColor,
            navigationBarColor: AppColorsDark.navigationBarColor,
          )
        : ColorTheme(
            iconColor: AppColorsLight.iconColor,
            textColor1: AppColorsLight.textColor1,
            textColor2: AppColorsLight.textColor2,
            appBarColor: AppColorsLight.appBarColor,
            dividerColor: AppColorsLight.dividerColor,
            backgroundColor: AppColorsLight.backgroundColor,
            errorSnackBarColor: AppColorsLight.errorSnackBarColor,
            incomingMessageBubbleColor:
                AppColorsLight.incomingMessageBubbleColor,
            outgoingMessageBubbleColor:
                AppColorsLight.outgoingMessageBubbleColor,
            incomingEmbedColor: AppColorsLight.incomingEmbedColor,
            outgoingEmbedColor: AppColorsLight.outgoingEmbedColor,
            selectedLabelColor: AppColorsLight.selectedLabelColor,
            unselectedLabelColor: AppColorsLight.unselectedLabelColor,
            indicatorColor: AppColorsLight.indicatorColor,
            blueColor: AppColorsLight.blueColor,
            greenColor: AppColorsLight.greenColor,
            yellowColor: AppColorsLight.yellowColor,
            greyColor: AppColorsLight.greyColor,
            statusBarColor: AppColorsLight.statusBarColor,
            navigationBarColor: AppColorsLight.navigationBarColor,
          );
  }
}

// THEME PROVIDERS
final darkThemeProvider = Provider((ref) => _darkTheme);
final lightThemeProvider = Provider((ref) => _theme);

// THEMES
// Light theme (Not implemented yet)
final _customTheme = CustomThemeData(isDarkTheme: false);
final _theme = ThemeData(
  brightness: Brightness.light,
  dialogTheme: const DialogTheme(
    backgroundColor: AppColorsLight.backgroundColor,
    titleTextStyle: TextStyle(color: AppColorsLight.textColor1, fontSize: 16),
    contentTextStyle: TextStyle(
      color: AppColorsLight.textColor1,
      fontSize: 16,
    ),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    actionsIconTheme: IconThemeData(
      color: AppColorsLight.iconColor,
    ),
    backgroundColor: AppColorsLight.appBarColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: AppColorsLight.appBarColor,
      systemNavigationBarColor: AppColorsLight.backgroundColor,
      systemNavigationBarDividerColor: AppColorsLight.backgroundColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColorsLight.greenColor,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColorsLight.backgroundColor,
  iconTheme: const IconThemeData(
    color: AppColorsLight.iconColor,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColorsLight.greenColor,
  ),
);

// Dark theme
final _customDarkTheme = CustomThemeData(isDarkTheme: true);
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  dialogTheme: const DialogTheme(
    backgroundColor: AppColorsDark.appBarColor,
    titleTextStyle: TextStyle(color: AppColorsLight.textColor1, fontSize: 16),
    contentTextStyle: TextStyle(
      color: AppColorsLight.textColor1,
      fontSize: 16,
    ),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    actionsIconTheme: IconThemeData(
      color: AppColorsDark.iconColor,
    ),
    backgroundColor: AppColorsDark.appBarColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: AppColorsDark.appBarColor,
      systemNavigationBarColor: AppColorsDark.backgroundColor,
      systemNavigationBarDividerColor: AppColorsDark.backgroundColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColorsDark.indicatorColor,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColorsDark.backgroundColor,
  iconTheme: const IconThemeData(
    color: AppColorsDark.iconColor,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColorsDark.greenColor,
  ),
);

// EXTENSION
extension CustomTheme on ThemeData {
  CustomThemeData get custom =>
      brightness == Brightness.dark ? _customDarkTheme : _customTheme;

  AssetImage themedImage(String name) {
    final path =
        brightness == Brightness.dark ? 'assets/images/dark' : 'assets/images';
    return AssetImage('$path/$name');
  }
}
