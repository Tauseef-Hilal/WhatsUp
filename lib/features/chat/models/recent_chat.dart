import 'package:whatsapp_clone/features/chat/models/message.dart';

class RecentChat {
  final Message message;
  final String name;
  final String avatarUrl;

  RecentChat({
    required this.message,
    required this.name,
    required this.avatarUrl,
  });

  factory RecentChat.fromMap(Map<String, dynamic> chatData) {
    return RecentChat(
      message: Message.fromMap(chatData['message']),
      name: chatData['name'],
      avatarUrl: chatData['avatarUrl'],
    );
  }

  @override
  String toString() {
    return 'Recent Chat => ${message.content}';
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message.toMap(),
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }
}
