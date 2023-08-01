import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/abc.dart';
import '../utils/storage_paths.dart';

class ImageService {
  static final ImageService instance = ImageService();

  Future<XFile?> _capturePhoto() async {
    if (!await hasPermission(Permission.camera)) return null;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    return image;
  }

  Future<XFile?> _pickImageFromGallery() async {
    if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    return image;
  }

  Future<List<XFile>?> _pickMultimedia() async {
    if (Platform.isIOS && !await hasPermission(Permission.photos)) return null;

    final picker = ImagePicker();
    final List<XFile> media = await picker.pickMultipleMedia();

    return media;
  }

  static Future<List<File>?> getImages({
    required ImageSource source,
    bool single = true,
  }) async {
    final images = <XFile>[];
    switch (source) {
      case ImageSource.camera:
        final image = await instance._capturePhoto();

        if (image == null) return null;
        images.add(image);

        break;
      default:
        if (single) {
          final image = await instance._pickImageFromGallery();

          if (image == null) return null;
          images.add(image);
        } else {
          final imageList = await instance._pickMultimedia();

          if (imageList == null || imageList.isEmpty) return null;
          images.addAll(imageList);
        }
    }

    for (var i = 0; i < images.length; i++) {
      XFile? compressedImage;
      try {
        compressedImage = (await FlutterImageCompress.compressAndGetFile(
          images[i].path,
          DeviceStorage.getMediaFilePath(images[i].name),
          quality: 30,
        ))!;

        images[i] = compressedImage;
      } catch (e) {
        await images[i].saveTo(DeviceStorage.getMediaFilePath(images[i].name));
        continue;
      }
    }

    return images.map((e) => File(e.path)).toList();
  }
}
