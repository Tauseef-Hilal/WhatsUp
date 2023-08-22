import 'dart:ui';

class AppColorsDark {
  static const iconColor = Color.fromRGBO(133, 148, 163, 1);
  static const textColor1 = Color.fromRGBO(233, 237, 240, 1);
  static const textColor2 = Color.fromRGBO(204, 209, 206, 1);
  static const appBarColor = Color.fromRGBO(31, 44, 52, 1);
  static const dividerColor = Color.fromRGBO(37, 45, 50, 1);
  static const backgroundColor = Color.fromRGBO(17, 27, 33, 1);
  static const errorSnackBarColor = Color.fromRGBO(211, 45, 81, 1);
  static const incomingMessageBubbleColor = Color.fromRGBO(31, 44, 51, 1);
  static const outgoingMessageBubbleColor = Color.fromRGBO(1, 92, 75, 1);
  static const incomingEmbedColor = Color.fromRGBO(25, 35, 40, 1);
  static const outgoingEmbedColor = Color.fromRGBO(0, 74, 64, 1);
  static const selectedLabelColor = Color.fromRGBO(5, 165, 133, 1);
  static const unselectedLabelColor = Color.fromRGBO(131, 151, 161, 1);
  static const indicatorColor = Color.fromRGBO(5, 165, 133, 1);
  static const statusBarColor = appBarColor;
  static const navigationBarColor = Color.fromRGBO(23, 36, 45, 1);

  static const blueColor = Color.fromRGBO(83, 189, 236, 1);
  static const greenColor = Color.fromRGBO(5, 165, 133, 1);
  static const yellowColor = Color.fromRGBO(255, 210, 121, 1);
  static const greyColor = Color.fromRGBO(134, 151, 161, 1);
}

class AppColorsLight {
  static const iconColor = Color.fromRGBO(248, 249, 249, 1);
  static const textColor1 = Color.fromRGBO(24, 24, 24, 1);
  static const textColor2 = Color.fromRGBO(0, 0, 0, 1);
  static const appBarColor = Color.fromRGBO(0, 128, 105, 1);
  static const dividerColor = Color.fromRGBO(37, 45, 50, 1);
  static const backgroundColor = Color.fromRGBO(252, 252, 252, 1);
  static const errorSnackBarColor = Color.fromRGBO(211, 45, 81, 1);
  static const incomingMessageBubbleColor = Color.fromRGBO(242, 242, 242, 1);
  static const outgoingMessageBubbleColor = Color.fromRGBO(215, 243, 203, 1);
  static const incomingEmbedColor = Color.fromRGBO(233, 232, 232, 1);
  static const outgoingEmbedColor = Color.fromRGBO(204, 234, 193, 1);
  static const selectedLabelColor = Color.fromRGBO(220, 255, 254, 1);
  static const unselectedLabelColor = Color.fromRGBO(168, 230, 219, 1);
  static const indicatorColor = Color.fromRGBO(220, 255, 254, 1);
  static const statusBarColor = Color.fromARGB(255, 243, 243, 243);
  static const navigationBarColor = Color.fromARGB(255, 244, 244, 244);

  static const blueColor = Color.fromRGBO(83, 189, 236, 1);
  static const greenColor = Color.fromRGBO(26, 181, 148, 1);
  static const yellowColor = Color.fromRGBO(255, 210, 121, 1);
  static const greyColor = Color.fromRGBO(102, 117, 127, 1);
}

class ColorTheme {
  final Color iconColor;
  final Color textColor1;
  final Color textColor2;
  final Color appBarColor;
  final Color dividerColor;
  final Color backgroundColor;
  final Color errorSnackBarColor;
  final Color incomingMessageBubbleColor;
  final Color outgoingMessageBubbleColor;
  final Color incomingEmbedColor;
  final Color outgoingEmbedColor;
  final Color selectedLabelColor;
  final Color unselectedLabelColor;
  final Color indicatorColor;
  final Color statusBarColor;
  final Color navigationBarColor;

  final Color blueColor;
  final Color greenColor;
  final Color yellowColor;
  final Color greyColor;

  ColorTheme({
    required this.iconColor,
    required this.textColor1,
    required this.textColor2,
    required this.appBarColor,
    required this.dividerColor,
    required this.backgroundColor,
    required this.errorSnackBarColor,
    required this.incomingMessageBubbleColor,
    required this.outgoingMessageBubbleColor,
    required this.incomingEmbedColor,
    required this.outgoingEmbedColor,
    required this.selectedLabelColor,
    required this.unselectedLabelColor,
    required this.indicatorColor,
    required this.statusBarColor,
    required this.navigationBarColor,
    required this.blueColor,
    required this.greenColor,
    required this.yellowColor,
    required this.greyColor,
  });
}
