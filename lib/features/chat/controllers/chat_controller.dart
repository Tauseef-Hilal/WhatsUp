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
    StateNotifierProvider.autoDispose<ChatControllerNotifier, ChatController>(
  (ref) => ChatControllerNotifier(ref: ref),
);

class ChatController {
  ChatController({this.hideElements = false, required this.messageController});

  final bool hideElements;
  final TextEditingController messageController;

  void dispose() {
    messageController.dispose();
  }

  void navigateToHome(BuildContext context, User user) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: user),
        ),
        (route) => false);
  }

  ChatController copyWith({
    bool? hideElements,
    TextEditingController? controller,
  }) {
    return ChatController(
      hideElements: hideElements ?? this.hideElements,
      messageController: controller ?? messageController,
    );
  }
}

class ChatControllerNotifier extends StateNotifier<ChatController> {
  ChatControllerNotifier({required this.ref})
      : super(ChatController(messageController: TextEditingController()));

  final AutoDisposeStateNotifierProviderRef ref;

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(hideElements: false);
    } else if (value != ' ') {
      state = state.copyWith(hideElements: true);
    } else {
      state.messageController.text = '';
    }
  }

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) async {
    MessageStatus status = MessageStatus.sent;

    if (!await isConnected()) {
      status = MessageStatus.pending;
    }

    final msg = Message(
      id: const Uuid().v4(),
      content: state.messageController.text.trim(),
      status: status,
      senderId: sender.id,
      receiverId: receiver.id,
      timestamp: Timestamp.now(),
    );

    ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(msg, sender, receiver);

    state.messageController.text = '';
    state = state.copyWith(hideElements: false);
  }
}
