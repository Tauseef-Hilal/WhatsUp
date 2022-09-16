import 'dart:io';

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
