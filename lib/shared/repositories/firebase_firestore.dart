import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';

final firebaseFirestoreRepositoryProvider = Provider(
  (ref) => FirebaseFirestoreRepo(firestore: FirebaseFirestore.instance),
);

class FirebaseFirestoreRepo {
  final FirebaseFirestore firestore;

  const FirebaseFirestoreRepo({
    required this.firestore,
  });

  Future<void> _updateChats(
    Message message,
    User target,
    User receiver,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(target.id)
        .collection('chats')
        .doc(receiver.id);

    await docRef.collection('messages').doc(message.id).set(message.toMap());
    await docRef.set({
      'recentChat': RecentChat(
        message: message,
        user: receiver,
      ).toMap()
    });
  }

  Future<void> sendMessage(Message message, User sender, User receiver) async {
    _updateChats(message, sender, receiver);
    _updateChats(message, receiver, sender);
  }

  Future<User?> getUserById(String id) async {
    final documentSnapshot = await firestore.collection('users').doc(id).get();

    return documentSnapshot.exists
        ? User.fromMap(documentSnapshot.data()!)
        : null;
  }

  Stream<List<RecentChat>> getRecentChatStream(String targetUserId) {
    return firestore
        .collection('users')
        .doc(targetUserId)
        .collection('chats')
        .orderBy('recentChat.message.timestamp')
        .snapshots()
        .map((event) {
      final chats = <RecentChat>[];
      for (var doc in event.docs) {
        chats.add(RecentChat.fromMap(doc.data()['recentChat']));
      }
      return chats;
    });
  }

  Stream<List<Message>> getChatStream(String targetUserId, String chatId) {
    return firestore
        .collection('users')
        .doc(targetUserId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((event) {
      final messages = <Message>[];
      for (var doc in event.docs) {
        messages.add(Message.fromMap(doc.data()));
      }
      return messages;
    });
  }

  Future<User?> getUserByPhone(String phoneNumber) async {
    phoneNumber = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    final snap = await firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return snap.size == 0 ? null : User.fromMap(snap.docs[0].data());
  }
}
