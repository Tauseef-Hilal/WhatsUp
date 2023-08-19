import 'dart:io';

enum AttachmentType {
  document("DOCUMENT"),
  image("IMAGE"),
  audio("AUDIO"),
  voice("VOICE"),
  video("VIDEO");

  const AttachmentType(this.value);
  final String value;

  factory AttachmentType.fromValue(String value) {
    final res = AttachmentType.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid attachment type';
    }

    return res.first;
  }
}

enum UploadStatus {
  notUploading("NOT_UPLOADING"),
  preparing("PREPARING"),
  uploading("UPLOADING"),
  uploaded("UPLOADED");

  const UploadStatus(this.value);
  final String value;
  factory UploadStatus.fromValue(String value) {
    final res = UploadStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid upload status';
    }

    return res.first;
  }
}

class Attachment {
  final String fileName;
  final AttachmentType type;
  final double? width;
  final double? height;
  UploadStatus uploadStatus;
  bool autoDownload;
  String fileExtension;
  int fileSize;
  String url;
  File? file;
  List<double>? samples;

  Attachment({
    required this.type,
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    this.uploadStatus = UploadStatus.notUploading,
    this.autoDownload = false,
    this.width,
    this.height,
    this.file,
    this.samples,
  });

  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(
      url: data["url"],
      fileName: data["fileName"],
      fileSize: data["fileSize"],
      fileExtension: data["fileExtension"],
      width: data["width"],
      height: data["height"],
      type: AttachmentType.fromValue(data["type"]),
      uploadStatus: UploadStatus.fromValue(data["uploadStatus"]),
      autoDownload: data["autoDownload"] ?? false,
      samples: data["samples"] != null
          ? List.castFrom<dynamic, double>(data["samples"])
          : null,
    );
  }

  @override
  String toString() {
    return fileName;
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "fileName": fileName,
      "fileSize": fileSize,
      "fileExtension": fileExtension,
      "type": type.value,
      "uploadStatus": uploadStatus.value,
      "autoDownload": autoDownload,
      "width": width,
      "height": height,
      "samples": samples,
    };
  }
}
