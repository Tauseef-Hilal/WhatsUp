import 'package:isar/isar.dart';

import '../../../features/chat/models/attachement.dart';
import '../../../features/chat/models/message.dart';

part 'messages.g.dart';

@collection
class StoredMessage {
  Id id = Isar.autoIncrement;
  String? messageId;
  String? chatId;
  String? content;
  String? senderId;
  String? receiverId;
  EmbeddedAttachment? attachment;
  DateTime? timestamp;

  @Enumerated(EnumType.value, 'value')
  MessageStatus? status;

  StoredMessage({
    this.messageId,
    this.chatId,
    this.content,
    this.senderId,
    this.receiverId,
    this.attachment,
    this.timestamp,
    this.status,
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
    this.type,
  });
}
