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

class Message {
  final String id;
  final String chatId;
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
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

      // For compatibility
      attachment: msgData["attachment"] != null
          ? Attachment.fromMap(msgData["attachment"])
          : null,
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
      "attachment": attachment?.toMap(),
    };
  }
}
