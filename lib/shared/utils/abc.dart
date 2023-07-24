import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

List<Country> get countriesList => CountryService().getAll();

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

String strFormattedTime(int seconds, [bool minWidth4 = false]) {
  if (seconds == 0) return "0:00";

  String result = DateFormat('HH:mm:ss').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  resultParts.removeWhere((element) => element == '00');

  if (minWidth4 && resultParts.length == 1) {
    resultParts = ["0", ...resultParts];
  }

  return resultParts.join(':');
}

String formattedTimestamp(Timestamp timestamp,
    [bool timeOnly = false, bool meridiem = false]) {
  DateTime now = DateTime.now();
  DateTime date = timestamp.toDate();

  if (now.day - date.day == 0 || timeOnly) {
    return meridiem
        ? DateFormat('hh:mm a').format(date)
        : DateFormat('HH:mm').format(date);
  } else if (now.day - date.day == 1) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

Future<File?> capturePhoto() async {
  if (!await hasPermission(Permission.camera)) return null;

  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  return image != null ? File(image.path) : null;
}

Future<File?> pickImageFromGallery() async {
  if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  return image != null ? File(image.path) : null;
}

Future<List<File>?> pickMultimedia() async {
  if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

  final picker = ImagePicker();
  final List<XFile> media = await picker.pickMultipleMedia();

  return media.map((e) => File(e.path)).toList();
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

Future<List<File>?> pickFiles({
  required FileType type,
  bool allowMultiple = false,
  bool allowCompression = true,
}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: type,
    allowCompression: allowCompression,
    allowMultiple: allowMultiple,
  );

  return result?.files.map((e) => File(e.path!)).toList();
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

Future<double> getKeyboardHeight() async {
  var sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getDouble('keyboardHeight')!;
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
