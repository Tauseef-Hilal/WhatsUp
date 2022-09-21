import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';

List<Country> get countriesList => CountryService().getAll();

String strFormattedTime(int seconds) {
  String result = DateFormat('H:m:s').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  resultParts.removeWhere((element) => element == '0');

  return resultParts.join(':');
}

String formattedTimestamp(Timestamp timestamp, [bool timeOnly = false]) {
  DateTime now = DateTime.now();
  DateTime date = timestamp.toDate();
  Duration timeDelta = now.difference(date);

  if (timeDelta.inDays < 1 || timeOnly) {
    return DateFormat('hh:mm a').format(date);
  } else if (timeDelta.inDays == 1) {
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
