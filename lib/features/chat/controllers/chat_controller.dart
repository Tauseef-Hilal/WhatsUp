import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';

import '../../../shared/repositories/firebase_storage.dart';
import '../../../shared/utils/abc.dart';
import '../models/attachement.dart';

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatStateNotifier, ChatState>(
  (ref) => ChatStateNotifier(ref: ref),
);

enum RecordingState {
  notRecording,
  recording,
  recordingLocked,
  paused,
}

class ChatState {
  ChatState({
    this.hideElements = false,
    this.recordingState = RecordingState.notRecording,
    required this.soundRecorder,
    required this.messageController,
  });

  final bool hideElements;
  final RecordingState recordingState;
  final TextEditingController messageController;
  final FlutterSoundRecorder soundRecorder;

  void dispose() {
    messageController.dispose();
    soundRecorder.closeRecorder();
  }

  ChatState copyWith({
    bool? hideElements,
    RecordingState? recordingState,
  }) {
    return ChatState(
      hideElements: hideElements ?? this.hideElements,
      recordingState: recordingState ?? this.recordingState,
      messageController: messageController,
      soundRecorder: soundRecorder,
    );
  }
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier({required this.ref})
      : super(
          ChatState(
            messageController: TextEditingController(),
            soundRecorder: FlutterSoundRecorder(logLevel: Level.error),
          ),
        );

  final AutoDisposeStateNotifierProviderRef ref;
  late final User self;
  late final User other;

  void initUsers(User self, User other) {
    this.self = self;
    this.other = other;
  }

  void initSoundRecorder() {
    state.soundRecorder.openRecorder();
    state.soundRecorder
        .setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context, User user) {
    Navigator.pop(context);
  }

  void setRecordingState(RecordingState recordingState) {
    state = state.copyWith(recordingState: recordingState);
  }

  Future<void> pauseRecording() async {
    await state.soundRecorder.pauseRecorder();
    setRecordingState(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await state.soundRecorder.resumeRecorder();
    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> onMicPressed() async {
    if (!await hasPermission(Permission.microphone)) return;

    await state.soundRecorder.startRecorder(
      toFile: "voice.aac",
      codec: Codec.aacADTS,
    );
    ref
        .read(chatControllerProvider.notifier)
        .setRecordingState(RecordingState.recording);
  }

  Future<void> onMicDragLeft(double dx, double deviceWidth) async {
    if (dx > deviceWidth * 0.6) return;

    await state.soundRecorder.stopRecorder();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> onMicDragUp(double dy, double deviceHeight) async {
    if (dy > deviceHeight - 100 ||
        state.recordingState == RecordingState.recordingLocked) return;

    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> cancelRecording() async {
    await state.soundRecorder.stopRecorder();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> onRecordingDone() async {
    final path = await state.soundRecorder.stopRecorder();
    setRecordingState(RecordingState.notRecording);

    final recordedFile = File(path!);
    final messageId = const Uuid().v4();
    final timestamp = Timestamp.now();
    final fileName = "AUD_${timestamp.seconds}.aac";

    await recordedFile.copy(await ref
        .read(firebaseStorageRepoProvider)
        .getMediaFilePath("${messageId}__$fileName"));

    ref.read(chatControllerProvider.notifier).sendMessageWithAttachments(
          Message(
            id: messageId,
            content: "",
            status: MessageStatus.pending,
            senderId: ref.read(chatControllerProvider.notifier).self.id,
            receiverId: ref.read(chatControllerProvider.notifier).other.id,
            timestamp: timestamp,
            attachment: Attachment(
              type: AttachmentType.audio,
              url: "",
              fileName: fileName,
              fileSize: recordedFile.lengthSync(),
              fileExtension: "aac",
              file: recordedFile,
            ),
          ),
          ref.read(chatControllerProvider.notifier).self,
          ref.read(chatControllerProvider.notifier).other,
        );
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(hideElements: false);
    } else if (value != ' ') {
      state = state.copyWith(hideElements: true);
    } else {
      state.messageController.text = "";
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

    state.messageController.text = "";
    state = state.copyWith(
      hideElements: false,
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
