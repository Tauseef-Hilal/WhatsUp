import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, seen }

class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
  // To be added later
  // final List attachments;
  // final MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
      id: msgData['id'],
      content: msgData['content'],
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
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
    };
  }
}
