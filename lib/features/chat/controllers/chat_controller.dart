import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';

import '../../../shared/repositories/firebase_storage.dart';
import '../../../shared/repositories/push_notifications.dart';
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
  final RecorderController soundRecorder;

  void dispose() {
    messageController.dispose();
    soundRecorder.dispose();
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
            soundRecorder: RecorderController(),
          ),
        );

  final AutoDisposeStateNotifierProviderRef ref;
  late User self;
  late User other;

  void initUsers(User self, User other) {
    this.self = self;
    this.other = other;
  }

  void initSoundRecorder() {
    state.soundRecorder.androidOutputFormat = AndroidOutputFormat.aac_adts;
    state.soundRecorder.sampleRate = 44100;
    state.soundRecorder.bitRate = 48000;
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context) {
    Navigator.pop(context);
  }

  void setRecordingState(RecordingState recordingState) {
    state = state.copyWith(recordingState: recordingState);
  }

  Future<void> pauseRecording() async {
    await state.soundRecorder.pause();
    setRecordingState(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await state.soundRecorder.record();
    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> cancelRecording() async {
    await state.soundRecorder.stop();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> startRecording() async {
    if (!await hasPermission(Permission.microphone)) return;

    await state.soundRecorder.record(
      path: "${DeviceStorage.tempDirPath}/voice.aac",
    );

    setRecordingState(RecordingState.recording);
  }

  Future<void> onMicDragLeft(double dx, double deviceWidth) async {
    if (dx > deviceWidth * 0.6) return;

    await state.soundRecorder.stop();
    setRecordingState(RecordingState.notRecording);
  }

  Future<void> onMicDragUp(double dy, double deviceHeight) async {
    if (dy > deviceHeight - 100 ||
        state.recordingState == RecordingState.recordingLocked) return;

    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> onRecordingDone() async {
    final path = await state.soundRecorder.stop();
    setRecordingState(RecordingState.notRecording);

    final recordedFile = File(path!);
    final messageId = const Uuid().v4();
    final timestamp = Timestamp.now();
    final ext = path.split(".").last;
    final fileName = "AUD_${timestamp.seconds}.$ext";

    await recordedFile.copy(await ref
        .read(firebaseStorageRepoProvider)
        .getMediaFilePath("${messageId}__$fileName"));

    final senderId = ref.read(chatControllerProvider.notifier).self.id;
    final receiverId = ref.read(chatControllerProvider.notifier).other.id;

    ref.read(chatControllerProvider.notifier).sendMessageWithAttachments(
          Message(
            id: messageId,
            content: "",
            status: MessageStatus.pending,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: timestamp,
            attachment: Attachment(
              type: AttachmentType.voice,
              url: "",
              fileName: fileName,
              fileSize: recordedFile.lengthSync(),
              fileExtension: ext,
              file: recordedFile,
            ),
          ),
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
    );

    state.messageController.text = "";
    state = state.copyWith(
      hideElements: false,
    );
  }

  Future<void> sendMessageNoAttachments(Message message) async {
    await IsarDb.addMessage(message);
    await ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(message..status = MessageStatus.sent);

    await IsarDb.updateMessage(message.id, status: message.status);
    await ref.read(pushNotificationsRepoProvider).sendPushNotification(message);
  }

  void sendMessageWithAttachments(Message message) {
    IsarDb.addMessage(message);
  }

  Future<void> markMessageAsSeen(Message message) async {
    await IsarDb.updateMessage(message.id, status: MessageStatus.seen);

    await ref.read(firebaseFirestoreRepositoryProvider).sendSystemMessage(
          message: SystemMessage(
            targetId: message.id,
            action: MessageAction.statusUpdate,
            update: MessageStatus.seen.value,
          ),
          receiverId: message.senderId,
        );
  }
}
