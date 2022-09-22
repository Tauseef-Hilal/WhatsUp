import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/home/views/base.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatController, bool>(
  (ref) => ChatController(ref: ref),
);

class ChatController extends StateNotifier<bool> {
  ChatController({required this.ref}) : super(false);

  final AutoDisposeStateNotifierProviderRef ref;
  late final TextEditingController messageController;

  void init() {
    messageController = TextEditingController();
    ref.read(emojiPickerControllerProvider.notifier).init();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context, User user) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user),
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

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) async {
    if (!await isConnected()) {
      return;
    }

    final msg = Message(
      id: const Uuid().v4(),
      content: messageController.text.trim(),
      status: MessageStatus.sent,
      senderId: sender.id,
      receiverId: receiver.id,
      timestamp: Timestamp.now(),
    );

    ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(msg, sender, receiver);

    messageController.text = '';
    state = false;
  }
}
