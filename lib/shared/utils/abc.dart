import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Country> get countriesList => CountryService().getAll();

String strFormattedTime(int seconds) {
  String result = DateFormat('HH:mm:s').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  resultParts.removeWhere((element) => element == '00');

  return resultParts.join(':');
}

String formattedTimestamp(Timestamp timestamp, [bool timeOnly = false]) {
  DateTime now = DateTime.now();
  DateTime date = timestamp.toDate();

  if (now.day - date.day == 0 || timeOnly) {
    return DateFormat('hh:mm a').format(date);
  } else if (now.day - date.day == 1) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

Future<File?> capturePhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  return image != null ? File(image.path) : null;
}

Future<File?> pickImageFromGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  return image != null ? File(image.path) : null;
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

Future<File?> pickFile([FileType fileType = FileType.any]) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: fileType);

  return result != null ? File(result.files.single.path!) : null;
}

Future<bool> hasPermission(Permission permission) async {
  PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  }

  status = await permission.request();
  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }

  return false;
}

Future<double> getKeyboardHeight() async {
  var sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getDouble('keyboardHeight')!;
}

StateProvider keyboardHeightProvider = StateProvider((ref) => 0.0,);