import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';

List<Country> get countriesList => CountryService().getAll();

User? getCurrentUser() {
  final userStr = SharedPref.instance.getString('user');
  if (userStr == null) return null;

  return User.fromMap(jsonDecode(userStr));
}

String getChatId(String senderId, String receiverId) {
  final charList = (senderId + receiverId).split('');
  charList.sort((a, b) => a.compareTo(b));

  return charList.join();
}

String strFormattedSize(num size) {
  size /= 1024;

  final suffixes = ["KB", "MB", "GB", "TB"];
  String suffix = "";

  for (suffix in suffixes) {
    if (size < 1024) {
      break;
    }

    size /= 1024;
  }

  return "${size.toStringAsFixed(2)}$suffix";
}

String timeFromSeconds(int seconds, [bool minWidth4 = false]) {
  if (seconds == 0) return "0:00";

  String result = DateFormat('HH:mm:ss').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  for (int i = 0; i < resultParts.length; i++) {
    if (resultParts[i] != "00") break;
    resultParts[i] = "";
  }
  resultParts.removeWhere((element) => element == "");

  if (minWidth4 && resultParts.length == 1) {
    resultParts = ["0", ...resultParts];
  }

  return resultParts.join(':');
}

String formattedTimestamp(Timestamp timestamp,
    [bool timeOnly = false, bool meridiem = false]) {
  DateTime now = DateTime.now();
  DateTime date = timestamp.toDate();

  if (timeOnly || datesHaveSameDay(now, date)) {
    return meridiem
        ? DateFormat('hh:mm a').format(date)
        : DateFormat('HH:mm').format(date);
  }

  if (isYesterday(date)) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

String dateFromTimestamp(Timestamp timestamp) {
  DateTime now = DateTime.now();
  DateTime date = timestamp.toDate();

  if (datesHaveSameDay(now, date)) {
    return 'Today';
  }

  if (isYesterday(date)) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return datesHaveSameDay(date, yesterday);
}

bool datesHaveSameDay(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}

String titleCased(String input) {
  if (input.isEmpty) {
    return input;
  }

  List<String> words = input.split(' ');
  List<String> titleWords = [];

  for (String word in words) {
    if (word.isNotEmpty) {
      String titleWord =
          word[0].toUpperCase() + word.substring(1).toLowerCase();
      titleWords.add(titleWord);
    }
  }

  return titleWords.join(' ');
}

Future<bool> isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {}

  return false;
}

Future<Contact?> pickContact() async {
  if (!await hasPermission(Permission.contacts)) return null;
  return await FlutterContacts.openExternalPick();
}

Future<bool> hasPermission(Permission permission) async {
  final status = await permission.request();
  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }

  return false;
}

double getKeyboardHeight() {
  return SharedPref.instance.getDouble('keyboardHeight')!;
}

Future<(double, double)> getImageDimensions(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = await decodeImageFromList(bytes);
  image.dispose();

  return (image.width.toDouble(), image.height.toDouble());
}

Future<(double, double)> getVideoDimensions(File videoFile) async {
  final videoController = VideoPlayerController.file(videoFile);
  await videoController.initialize();

  final videoSize = videoController.value.size;
  videoController.dispose();

  return (videoSize.width, videoSize.height);
}
