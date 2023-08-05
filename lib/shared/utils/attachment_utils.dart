import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'abc.dart';

Future<List<File>?> pickMultimedia() async {
  if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

  final picker = ImagePicker();

  try {
    final List<XFile> media = await picker.pickMultipleMedia();
    return media.isNotEmpty ? media.map((e) => File(e.path)).toList() : null;
  } catch (e) {
    return null;
  }
}

Future<File?> pickImageFromGallery() async {
  if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  return image != null ? File(image.path) : null;
}

Future<File?> capturePhoto() async {
  if (!await hasPermission(Permission.camera)) return null;

  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  return image != null ? File(image.path) : null;
}

Future<List<File>?> pickFiles({
  required FileType type,
}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: type,
    allowCompression: false,
    allowMultiple: true,
  );

  return result?.files.map((e) => File(e.path!)).toList();
}
