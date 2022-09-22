import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus {
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
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
  final MessageStatus status;
  // To be added later
  // final List attachments;

  Message({
    required this.id,
    required this.content,
    required this.status,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
      id: msgData['id'],
      content: msgData['content'],
      status: MessageStatus.fromValue(msgData['status']),
      senderId: msgData['senderId'],
      receiverId: msgData['receiverId'],
      timestamp: msgData['timestamp'],
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
    };
  }
}
