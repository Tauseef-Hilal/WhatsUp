import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/home/views/base.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatController, bool>(
  (ref) => ChatController(),
);

class ChatController extends StateNotifier<bool> {
  ChatController() : super(false);

  late final TextEditingController messageController;

  void init() {
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context, String userId) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userId: userId),
        ),
        (route) => false);
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = false;
    } else if (value != ' ') {
      state = true;
    } else {
      messageController.text = '';
    }
  }

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) {
    final msg = Message(
      content: messageController.text.trim(),
      senderId: sender.id,
      timestamp: Timestamp.now(),
    );

    ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(msg, sender, receiver);

    messageController.text = '';
    state = false;
  }
}
