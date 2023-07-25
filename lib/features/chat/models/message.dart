import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';

enum MessageStatus {
  pending('PENDING'),
  sent('SENT'),
  delivered('DELIVERED'),
  seen('SEEN');

  const MessageStatus(this.value);
  final String value;

  factory MessageStatus.fromValue(String value) {
    final res = MessageStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid status code';
    }

    return res.first;
  }
}

enum MessageType {
  normalMessage('NORMAL_MESSAGE'),
  replacementMessage('SYSTEM_MESSAGE');

  const MessageType(this.value);
  final String value;

  factory MessageType.fromValue(String value) {
    final res = MessageType.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid message type';
    }

    return res.first;
  }
}

class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
  final MessageType type;
  final Attachment? attachment;
  MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.status,
    this.type = MessageType.normalMessage,
    this.attachment,
  });

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
      id: msgData['id'],
      content: msgData['content'],
      status: MessageStatus.fromValue(msgData['status']),
      senderId: msgData['senderId'],
      receiverId: msgData['receiverId'],
      timestamp: msgData['timestamp'],
      type: MessageType.fromValue(msgData['type']),
      attachment: msgData["attachment"] != null
          ? Attachment.fromMap(msgData["attachment"])
          : null,
    );
  }

  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    String? receiverId,
    Timestamp? timestamp,
    MessageStatus? status,
    MessageType? type,
    Attachment? attachment,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      attachment: attachment ?? this.attachment,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return content;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'status': status.value,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'type': type.value,
      "attachment": attachment?.toMap(),
    };
  }
}
