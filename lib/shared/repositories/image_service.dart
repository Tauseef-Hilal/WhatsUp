import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';

import '../utils/abc.dart';

typedef DecodingFunction = Future<Image?> Function(String);

class ImageService {
  static final ImageService instance = ImageService();
  static final Map<String, DecodingFunction> extensionDecoderMapper = {
    "jpg": decodeJpgFile,
    "jpeg": decodeJpgFile,
    "png": decodePngFile,
    "gif": decodeGifFile,
    "tiff": decodeTiffFile,
    "bmp": decodeBmpFile,
  };

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
    final imagePaths = <String>[];
    switch (source) {
      case ImageSource.camera:
        final image = await instance._capturePhoto();

        if (image == null) return null;
        imagePaths.add(image.path);

        break;
      default:
        if (single) {
          final image = await instance._pickImageFromGallery();

          if (image == null) return null;
          imagePaths.add(image.path);
        } else {
          final imageList = await instance._pickMultimedia();

          if (imageList == null || imageList.isEmpty) return null;
          imagePaths.addAll(imageList.map((e) => e.path));
        }
    }

    final results = await Future.wait(
      imagePaths.map((path) =>
          extensionDecoderMapper[path.split('.').last]?.call(path) ??
          Future.value(File(path))),
    );

    final images = <File>[];
    for (var i = 0; i < results.length; i++) {
      var result = results[i];

      if (result is File) {
        images.add(result);
        continue;
      }

      result = result as Image;
      final imagePath = imagePaths[i];
      final newPath = DeviceStorage.getTempFilePath(imagePath);
      final aspectRatio = result.width / result.height;

      double width, height;
      if (result.height > result.width) {
        height = min(1280, result.height * 1.0);
        width = aspectRatio * height;
      } else {
        width = min(1280, result.width * 1.0);
        height = width / aspectRatio;
      }

      result = copyResize(
        result,
        width: width.round(),
        height: height.round(),
        interpolation: Interpolation.linear,
      );

      final success = await encodeJpgFile(
        DeviceStorage.getTempFilePath(imagePath),
        result,
        quality: 50,
      );

      if (!success) {
        images.add(File(imagePath));
        continue;
      }

      images.add(File(newPath));
    }

    return images;
  }
}
