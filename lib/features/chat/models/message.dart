import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, seen }

class Message {
  final String content;
  final String senderId;
  final Timestamp timestamp;
  // To be added later
  // final List attachments;
  // final MessageStatus status;

  Message({
    required this.content,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
      content: msgData['content'],
      senderId: msgData['senderId'],
      timestamp: msgData['timestamp'],
    );
  }

  @override
  String toString() {
    return content;
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }
}
