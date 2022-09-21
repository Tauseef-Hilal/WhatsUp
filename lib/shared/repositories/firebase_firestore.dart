import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

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
    String targetUserId,
    String chatId,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(targetUserId)
        .collection('chats')
        .doc(chatId);

    await docRef.set({'latest': message.toMap()});
    await docRef.collection('messages').add(message.toMap());
  }

  Future<void> sendMessage(Message message, User sender, User receiver) async {
    _updateChats(message, sender.id, receiver.id);
    _updateChats(message, receiver.id, sender.id);
  }

  Future<User?> getUserById(String id) async {
    final documentSnapshot = await firestore.collection('users').doc(id).get();

    return documentSnapshot.exists
        ? User.fromMap(documentSnapshot.data()!)
        : null;
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
