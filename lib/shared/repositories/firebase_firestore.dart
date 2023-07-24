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

  Future<void> setActivityStatus({
    required String userId,
    required String statusValue,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .update({'activityStatus': statusValue});
  }

  Stream<UserActivityStatus> userActivityStatusStream({required userId}) {
    return firestore.collection('users').doc(userId).snapshots().map((event) {
      return UserActivityStatus.fromValue(event.data()!['activityStatus']);
    });
  }

  Future<void> sendMessage(
    Message message,
    User sender,
    User receiver, [
    bool updateRecentChats = true,
  ]) async {
    await firestore
        .collection('chats')
        .doc(message.chatId)
        .set(message.toMap());
  }

  Future<User?> getUserById(String id) async {
    final documentSnapshot = await firestore.collection('users').doc(id).get();

    return documentSnapshot.exists
        ? User.fromMap(documentSnapshot.data()!)
        : null;
  }

  Future<void> markChatAsRead(String chatId) async {
    await firestore
        .collection('chats')
        .doc(chatId)
        .set({'read': true}, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> getMessageStream(String chatId) {
    return firestore.collection('chats').doc(chatId).snapshots().map(
      (docSnap) {
        return docSnap.data()!;
      },
    );
  }

  Stream<List<Message>> getChatStream(String ownId) {
    return firestore
        .collection('chats')
        .where('senderId', isNotEqualTo: ownId)
        .snapshots()
        .map(
      (querySnap) {
        final messages = <Message>[];

        for (final docSnap in querySnap.docChanges) {
          final docData = docSnap.doc.data()!;
          if (docData['read'] != null) continue;
          
          messages.add(Message.fromMap(docData));
          markChatAsRead(docData['chatId']);
        }

        return messages;
      },
    );
  }

  Future<User?> getUserByPhone(String phoneNumber) async {
    phoneNumber = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    QuerySnapshot<Map<String, dynamic>> snap;
    if (phoneNumber.startsWith('+')) {
      snap = await firestore
          .collection('users')
          .where('phone.rawNumber', isEqualTo: phoneNumber)
          .get();
    } else {
      snap = await firestore
          .collection('users')
          .where('phone.number', isEqualTo: phoneNumber)
          .get();
    }

    return snap.size == 0 ? null : User.fromMap(snap.docs[0].data());
  }
}
