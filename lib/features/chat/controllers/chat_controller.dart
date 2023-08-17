import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/utils/attachment_utils.dart';
import 'package:whatsapp_clone/shared/utils/storage_paths.dart';
import 'package:whatsapp_clone/shared/widgets/camera.dart';

import '../../../shared/repositories/compression_service.dart';
import '../../../shared/repositories/push_notifications.dart';
import '../../../shared/utils/abc.dart';
import '../../../shared/widgets/gallery.dart';
import '../models/attachement.dart';
import '../views/attachment_sender.dart';

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
    this.showScrollBtn = false,
    this.unreadCount = 0,
    required this.recordingSamples,
    required this.soundRecorder,
    required this.messageController,
  });

  final bool hideElements;
  final RecordingState recordingState;
  final TextEditingController messageController;
  final FlutterSoundRecorder soundRecorder;
  final bool showScrollBtn;
  final int unreadCount;
  final List<RecordingDisposition> recordingSamples;

  void dispose() {
    messageController.dispose();
    soundRecorder.closeRecorder();
  }

  ChatState copyWith({
    bool? hideElements,
    RecordingState? recordingState,
    bool? showScrollBtn,
    int? unreadCount,
    List<RecordingDisposition>? recordingSamples,
  }) {
    return ChatState(
      hideElements: hideElements ?? this.hideElements,
      recordingState: recordingState ?? this.recordingState,
      showScrollBtn: showScrollBtn ?? this.showScrollBtn,
      unreadCount: unreadCount ?? this.unreadCount,
      messageController: messageController,
      soundRecorder: soundRecorder,
      recordingSamples: recordingSamples ?? this.recordingSamples,
    );
  }
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier({required this.ref})
      : super(
          ChatState(
            messageController: TextEditingController(),
            soundRecorder: FlutterSoundRecorder(logLevel: Level.error),
            recordingSamples: [],
          ),
        );

  final AutoDisposeStateNotifierProviderRef ref;
  late User self;
  late User other;
  late String otherUserContactName;
  StreamSubscription<RecordingDisposition>? recordingStream;

  void initUsers(User self, User other, String otherUserContactName) {
    this.self = self;
    this.other = other;
    this.otherUserContactName = otherUserContactName;
  }

  Future<void> initRecorder() async {
    await state.soundRecorder.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    state.soundRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 120),
    );
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
    await state.soundRecorder.pauseRecorder();
    setRecordingState(RecordingState.paused);
  }

  Future<void> resumeRecording() async {
    await state.soundRecorder.resumeRecorder();
    setRecordingState(RecordingState.recordingLocked);
  }

  Future<void> cancelRecording() async {
    await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;
    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );
  }

  Future<void> startRecording() async {
    if (!await hasPermission(Permission.microphone)) return;
    await state.soundRecorder.startRecorder(
      codec: Codec.aacADTS,
      sampleRate: 44100,
      bitRate: 48000,
      toFile: "voice.aac",
    );

    recordingStream = state.soundRecorder.onProgress!.listen(
      recordingListener,
    );
    setRecordingState(RecordingState.recording);
  }

  void recordingListener(RecordingDisposition data) {
    state = state.copyWith(
      recordingSamples: state.recordingSamples..add(data),
    );
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

  Future<void> onRecordingDone() async {
    final path = await state.soundRecorder.stopRecorder();
    recordingStream?.cancel();
    recordingStream = null;

    final samples = state.recordingSamples.map((e) => e.decibels ?? 0).toList();

    state = state.copyWith(
      recordingSamples: [],
      recordingState: RecordingState.notRecording,
    );

    final recordedFile = File(path!);
    final messageId = const Uuid().v4();
    final timestamp = Timestamp.now();
    final ext = path.split(".").last;
    final fileName = "AUD_${timestamp.seconds}.$ext";

    await recordedFile.copy(
      DeviceStorage.getMediaFilePath(fileName),
    );

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
              uploadStatus: UploadStatus.uploading,
              file: recordedFile,
              samples: samples,
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

  void toggleScrollBtnVisibility() {
    state = state.copyWith(showScrollBtn: !state.showScrollBtn);
  }

  void setUnreadCount(int count) {
    if (state.unreadCount == count) return;
    state = state.copyWith(unreadCount: count);
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

    // Delay for smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      ref
          .read(firebaseFirestoreRepositoryProvider)
          .sendMessage(message..status = MessageStatus.sent)
          .then((_) {
        IsarDb.updateMessage(message.id, status: message.status);
        ref.read(pushNotificationsRepoProvider).sendPushNotification(message);
      });
    });
  }

  void sendMessageWithAttachments(Message message) async {
    await IsarDb.addMessage(message);
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

  Future<void> navigateToCameraView(BuildContext context) async {
    final cameras = await availableCameras();
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraView(cameras: cameras)),
    );
  }

  Future<List<Attachment>?> pickAttachmentsFromGallery(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    if (Platform.isAndroid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>  Gallery(
            title: 'Send to $otherUserContactName'
          ),
        ),
      );
      return null;
    }

    final key = showLoading(context);

    List<File>? files = await pickMultimedia();
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = await prepareAttachments(files, shouldCompress: true);
    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  Future<void> pickAudioFiles(
    BuildContext context,
  ) async {
    final key = showLoading(context);

    List<File>? files = await pickFiles(type: FileType.audio);
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return;
    }

    final attachments = await prepareAttachments(files, areDocuments: false);

    if (!mounted) return;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
  }

  Future<List<Attachment>?> pickDocuments(
    BuildContext context, {
    bool returnAttachments = false,
  }) async {
    final key = showLoading(context);

    List<File>? files = await pickFiles(type: FileType.any);
    if (files == null) {
      Navigator.pop(key.currentContext!);
      return null;
    }

    final attachments = await prepareAttachments(files, areDocuments: true);
    if (returnAttachments) {
      Navigator.pop(key.currentContext!);
      return attachments;
    }

    if (!mounted) return null;
    Navigator.pop(key.currentContext!);
    navigateToAttachmentSender(context, attachments);
    return null;
  }

  GlobalKey showLoading(context) {
    final dialogKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          key: dialogKey,
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text(
                'Preparing media',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    return dialogKey;
  }

  Future<List<Attachment>> prepareAttachments(
    List<File> files, {
    bool shouldCompress = false,
    bool areDocuments = false,
  }) async {
    if (shouldCompress) {
      files = await CompressionService.compressFiles(files);
    }

    return await createAttachmentsFromFiles(files, areDocuments: areDocuments);
  }

  Future<List<Attachment>> createAttachmentsFromFiles(
    List<File> files, {
    bool areDocuments = false,
  }) async {
    return await Future.wait(
      files.map((file) async {
        final type = areDocuments
            ? AttachmentType.document
            : AttachmentType.fromValue(
                lookupMimeType(file.path)?.split("/")[0].toUpperCase() ??
                    'DOCUMENT',
              );

        double? width, height;
        if (type == AttachmentType.image) {
          (width, height) = await getImageDimensions(File(file.path));
        } else if (type == AttachmentType.video) {
          (width, height) = await getVideoDimensions(File(file.path));
        }

        final fileName = file.path.split("/").last;

        return Attachment(
          type: type,
          url: "",
          fileName: fileName,
          fileSize: file.lengthSync(),
          fileExtension: fileName.split(".").last,
          width: width,
          height: height,
          file: file,
        );
      }),
    );
  }

  void navigateToAttachmentSender(
    BuildContext context,
    List<Attachment> attachments,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AttachmentMessageSender(
          attachments: attachments,
        ),
      ),
    );
  }
}
