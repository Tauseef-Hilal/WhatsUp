import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
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
  systemMessage('SYSTEM_MESSAGE');

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
  final String chatId;
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
  final MessageType type;
  final Attachment? attachment;
  MessageStatus status;

  Message({
    required this.id,
    required this.chatId,
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
      chatId: msgData['chatId'],
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

  factory Message.fakeMessage() {
    return Message(
      id: const Uuid().v4(),
      chatId: 'chatId',
      content: 'FAKE MESSAGE',
      senderId: 'senderId',
      receiverId: 'receiverId',
      timestamp: Timestamp.now(),
      status: MessageStatus.sent,
    );
  }

  @override
  String toString() {
    return content;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
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
