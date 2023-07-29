import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

class RecentChat {
  final Message message;
  final User user;
  int unreadCount;

  RecentChat({
    required this.message,
    required this.user,
    this.unreadCount = 0,
  });

  factory RecentChat.fromMap(Map<String, dynamic> chatData) {
    return RecentChat(
      message: Message.fromMap(chatData['message']),
      user: User.fromMap(chatData['user']),
      unreadCount: chatData['unreadCount'],
    );
  }

  @override
  String toString() {
    return 'Recent Chat => ${message.content}';
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message.toMap(),
      'user': user.toMap(),
      'unreadCount': unreadCount,
    };
  }
}
