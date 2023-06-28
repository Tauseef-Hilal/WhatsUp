import 'dart:io';

enum AttachmentType {
  document("DOCUMENT"),
  image("IMAGE"),
  audio("AUDIO"),
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

class Attachment {
  final String fileName;
  final String fileSize;
  final AttachmentType type;
  String url;
  File? file;

  Attachment({
    required this.type,
    required this.url,
    required this.fileName,
    required this.fileSize,
    this.file,
  });

  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(
      url: data["url"],
      fileName: data["fileName"],
      fileSize: data["fileSize"],
      type: AttachmentType.fromValue(data["type"]),
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
      "type": type.value,
    };
  }
}
