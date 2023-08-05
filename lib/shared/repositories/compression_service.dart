import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
import 'package:mime/mime.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';

typedef ImageDecodingFunction = Future<Image?> Function(String);
typedef CompressorFunction = Future<File> Function(File);

class CompressionService {
  static final CompressionService instance = CompressionService();

  CompressorFunction? _getCompressorFuncByType(String fileType) {
    return {
      "image": compressImage,
    }[fileType];
  }

  ImageDecodingFunction? _getImgDecodingFuncByExt(String extension) {
    return {
      "jpg": decodeJpgFile,
      "jpeg": decodeJpgFile,
      "png": decodePngFile,
      "gif": decodeGifFile,
      "tiff": decodeTiffFile,
      "bmp": decodeBmpFile,
    }[extension];
  }

  static Future<List<File>> compressFiles(List<File> files) async {
    return await Future.wait(
      files.map((file) {
        return instance
                ._getCompressorFuncByType(
                  lookupMimeType(file.path)?.split("/").first ?? "",
                )
                ?.call(file) ??
            Future.value(file);
      }),
    );
  }

  static Future<File> compressImage(File file) async {
    var image = await instance
        ._getImgDecodingFuncByExt(file.path.split('.').last)
        ?.call(file.path);

    if (image == null) {
      return file;
    }

    final aspectRatio = image.width / image.height;
    double width, height;

    if (image.height > image.width) {
      height = min(1280, image.height * 1.0);
      width = aspectRatio * height;
    } else {
      width = min(1280, image.width * 1.0);
      height = width / aspectRatio;
    }

    image = copyResize(
      image,
      width: width.round(),
      height: height.round(),
      interpolation: Interpolation.linear,
    );

    final newPath = DeviceStorage.getTempFilePath(file.path.split("/").last);
    final didConvert = await encodeJpgFile(
      newPath,
      image,
      quality: 50,
    );

    if (!didConvert) {
      return file;
    }

    return File(newPath);
  }
}
