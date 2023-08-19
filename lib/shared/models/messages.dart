import 'package:isar/isar.dart';

import '../../../features/chat/models/attachement.dart';
import '../../../features/chat/models/message.dart';

part 'messages.g.dart';

@collection
class StoredMessage {
  Id id = Isar.autoIncrement;
  String messageId;
  String chatId;
  String content;
  String senderId;
  String receiverId;
  DateTime timestamp;
  EmbeddedAttachment? attachment;

  @Enumerated(EnumType.value, 'value')
  MessageStatus status;

  StoredMessage({
    required this.messageId,
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.status,
    this.attachment,
  });
}

@embedded
class EmbeddedAttachment {
  String? fileName;
  String? fileExtension;
  int? fileSize;
  double? width;
  double? height;
  String? url;
  List<double>? samples;
  bool? autoDownload;

  @Enumerated(EnumType.value, 'value')
  UploadStatus? uploadStatus;

  @Enumerated(EnumType.value, 'value')
  AttachmentType? type;

  EmbeddedAttachment({
    this.fileName,
    this.fileExtension,
    this.fileSize,
    this.width,
    this.height,
    this.url,
    this.uploadStatus,
    this.autoDownload,
    this.type,
    this.samples,
  });
}
