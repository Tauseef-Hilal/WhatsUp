import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
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

  Future<void> _updateChats(
    Message message,
    User target,
    User receiver,
    bool updateRecentChats,
  ) async {
    final receiverDocRef = firestore
        .collection('users')
        .doc(target.id)
        .collection('chats')
        .doc(receiver.id);

    await receiverDocRef
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    if (!updateRecentChats) return;

    await receiverDocRef.set({
      'recentChat': RecentChat(
        message: message,
        user: receiver,
      ).toMap()
    });
  }

  Future<void> sendMessage(
    Message message,
    User sender,
    User receiver, [
    bool updateRecentChats = true,
  ]) async {
    await _updateChats(message, sender, receiver, updateRecentChats);
    await _updateChats(message, receiver, sender, updateRecentChats);
  }

  Future<void> updateMessage(Message message, Map<String, dynamic> data) async {
    var chatDoc = firestore
        .collection('users')
        .doc(message.senderId)
        .collection('chats')
        .doc(message.receiverId);
    var recent = (await chatDoc.get()).data()!['recentChat'];
    await chatDoc.set({
      'recentChat': recent
        ..addAll(
          {'message': recent['message']..addAll(data)},
        )
    }, SetOptions(merge: true));

    var msgDoc = chatDoc.collection('messages').doc(message.id);
    await msgDoc.set(data, SetOptions(merge: true));

    chatDoc = firestore
        .collection('users')
        .doc(message.receiverId)
        .collection('chats')
        .doc(message.senderId);

    recent = (await chatDoc.get()).data()!['recentChat'];
    await chatDoc.set({
      'recentChat': recent
        ..addAll(
          {'message': recent['message']..addAll(data)},
        )
    }, SetOptions(merge: true));

    msgDoc = chatDoc.collection('messages').doc(message.id);
    await msgDoc.set(data, SetOptions(merge: true));
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
        .orderBy('recentChat.message.timestamp', descending: true)
        .snapshots()
        .map((event) {
      final chats = <RecentChat>[];
      for (var doc in event.docs) {
        final isNew =
            doc.data()['recentChat']["message"]["senderId"] != targetUserId &&
                doc.data()['recentChat']["message"]["status"] != "SEEN";
        chats.add(
          RecentChat.fromMap(doc.data()['recentChat'])..isNewForUser = isNew,
        );
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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((event) {
      final messages = <Message>[];
      for (var doc in event.docs) {
        final data = doc.data();
        if (data['attachment'] != null &&
            data['senderId'] != targetUserId &&
            (data['attachment']['url'].isEmpty ||
                data['attachment']['url'] == 'uploading')) {
          continue;
        }
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
