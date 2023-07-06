import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatControllerNotifier, ChatController>(
  (ref) => ChatControllerNotifier(ref: ref),
);

class ChatController {
  ChatController({
    this.hideElements = false,
    required this.messageController,
  });

  final bool hideElements;
  final TextEditingController messageController;

  void dispose() {
    messageController.dispose();
  }

  ChatController copyWith({
    bool? hideElements,
    bool? isRecording,
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
      : super(
          ChatController(messageController: TextEditingController()),
        );

  final AutoDisposeStateNotifierProviderRef ref;
  late final User self;
  late final User other;

  init(User self, User other) async {
    this.self = self;
    this.other = other;
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context, User user) {
    Navigator.pop(context);
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(hideElements: false);
    } else if (value != ' ') {
      state = state.copyWith(hideElements: true);
    } else {
      state = state.copyWith(controller: TextEditingController());
    }
  }

  void onSendBtnPressed(WidgetRef ref, User sender, User receiver) async {
    sendMessageNoAttachments(
      Message(
        id: const Uuid().v4(),
        content: state.messageController.text.trim(),
        status: MessageStatus.pending,
        senderId: sender.id,
        receiverId: receiver.id,
        timestamp: Timestamp.now(),
      ),
      sender,
      receiver,
    );

    state = state.copyWith(
      hideElements: false,
      controller: TextEditingController(),
    );
  }

  void sendMessageNoAttachments(Message message, User sender, User receiver) {
    final firestore = ref.read(firebaseFirestoreRepositoryProvider);

    firestore.sendMessage(message, sender, receiver).then((_) {
      firestore.updateMessage(message, {"status": "SENT"});
    });
  }

  void sendMessageWithAttachments(Message message, User sender, User receiver) {
    final firestore = ref.read(firebaseFirestoreRepositoryProvider);
    firestore.sendMessage(message, sender, receiver, false);
  }
}
