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

final chatInputControllerProvider =
    StateNotifierProvider.autoDispose<ChatInputController, bool>(
  (ref) => ChatInputController(ref: ref),
);

// class ChatController {
//   ChatController();

//   final TextEditingController messageController = TextEditingController();

//   void dispose() {
//     messageController.dispose();
//   }

//   void navigateToHome(BuildContext context, User user) {
//     Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomePage(user: user),
//         ),
//         (route) => false);
//   }
// }

class ChatInputController extends StateNotifier<bool> {
  ChatInputController({required this.ref}) : super(false);

  final AutoDisposeStateNotifierProviderRef ref;
  final messageController = TextEditingController();

  void init() {
    ref
        .read(emojiPickerControllerProvider.notifier)
        .init(keyboardVisibility: false);
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
    MessageStatus status = MessageStatus.sent;

    if (!await isConnected()) {
      status = MessageStatus.pending;
    }

    final msg = Message(
      id: const Uuid().v4(),
      content: messageController.text.trim(),
      status: status,
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
