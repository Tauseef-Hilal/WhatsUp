import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';

import '../../features/chat/models/message.dart';

final pushNotificationsRepoProvider = Provider(
  (ref) => PushNotificationsRepo(FirebaseMessaging.instance, ref),
);

class PushNotificationsRepo {
  final FirebaseMessaging instance;
  final ProviderRef ref;

  PushNotificationsRepo(this.instance, this.ref);

  Future<void> init({
    required Future<void> Function(RemoteMessage) onMessageOpenedApp,
  }) async {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    instance.onTokenRefresh.listen((token) => handleTokenRefresh(token, ref));
  }

  Future<void> sendPushNotification(Message message) async {
    final token = await ref
        .read(firebaseFirestoreRepositoryProvider)
        .getFcmToken(message.receiverId);

    const String url =
        'https://wa_notifications-1-q2097095.deta.app/new_message';
    final Map<String, String> headers = {"Content-Type": "application/json"};

    String messageContent = message.content;
    if (message.attachment != null) {
      messageContent = "Sent an attachment";
    }

    final user = getCurrentUser()!;
    final String messageJson = jsonEncode(
      {
        'token': token,
        'messageId': message.id,
        'messageContent': messageContent,
        'authorId': user.id,
        'authorName': user.name,
      },
    );

    await post(
      Uri.parse(url),
      headers: headers,
      body: messageJson,
    );
  }
}

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  final data = message.data;

  await ProviderContainer()
      .read(firebaseFirestoreRepositoryProvider)
      .sendSystemMessage(
        message: SystemMessage(
          targetId: data['messageId'],
          action: MessageAction.statusUpdate,
          update: MessageStatus.delivered.value,
        ),
        receiverId: data['authorId'],
      );
}

void handleTokenRefresh(String newToken, ProviderRef ref) {
  final oldToken = SharedPref.instance.getString('fcmToken');
  if (newToken == oldToken) return;

  SharedPref.instance.setString('fcmToken', newToken);
  ref.read(firebaseFirestoreRepositoryProvider).setFcmToken(newToken);
}
