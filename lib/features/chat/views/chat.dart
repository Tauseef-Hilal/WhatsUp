import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/buttons.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/message_cards.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import 'widgets/attachment_sender.dart';

class ChatPage extends ConsumerStatefulWidget {
  final User self;
  final User other;
  final String otherUserContactName;

  const ChatPage({
    super.key,
    required this.self,
    required this.other,
    required this.otherUserContactName,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    ref
        .read(chatControllerProvider.notifier)
        .initUsers(widget.self, widget.other);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final self = widget.self;
    final other = widget.other;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 18,
              backgroundImage: CachedNetworkImageProvider(other.avatarUrl),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserContactName,
                  style: Theme.of(context).custom.textTheme.titleMedium,
                ),
                StreamBuilder<UserActivityStatus>(
                  stream: ref
                      .read(firebaseFirestoreRepositoryProvider)
                      .userActivityStatusStream(userId: other.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    return snapshot.data!.value == 'Online'
                        ? Text(
                            'Online',
                            style: Theme.of(context).custom.textTheme.caption,
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 32.0,
        leading: IconButton(
          onPressed: () => ref
              .read(chatControllerProvider.notifier)
              .navigateToHome(context, self),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam_rounded,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: Theme.of(context).themedImage('chat_bg.png'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const Expanded(
              child: ChatStream(),
            ),
            const SizedBox(
              height: 8.0,
            ),
            ChatInputContainer(
              self: self,
              other: other,
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatInputContainer extends ConsumerStatefulWidget {
  const ChatInputContainer({
    super.key,
    required this.self,
    required this.other,
  });

  final User self;
  final User other;

  @override
  ConsumerState<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends ConsumerState<ChatInputContainer> {
  final double keyboardHeight = SharedPref.getDouble('keyboardHeight');

  @override
  void initState() {
    ref.read(chatControllerProvider.notifier).initSoundRecorder();
    ref
        .read(emojiPickerControllerProvider.notifier)
        .init(keyboardVisibility: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final hideElements = ref.watch(chatControllerProvider).hideElements;
    final showEmojiPicker = ref.watch(emojiPickerControllerProvider);
    final recordingState = ref.watch(chatControllerProvider).recordingState;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.light
                ? colorTheme.greyColor
                : colorTheme.iconColor),
      ),
      child: Column(
        children: [
          recordingState != RecordingState.recordingLocked &&
                  recordingState != RecordingState.paused
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorTheme.appBarColor
                                    : colorTheme.backgroundColor,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: recordingState == RecordingState.notRecording
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: GestureDetector(
                                          onTap: ref
                                              .read(
                                                  emojiPickerControllerProvider
                                                      .notifier)
                                              .toggleEmojiPicker,
                                          child: Icon(
                                            showEmojiPicker == 1
                                                ? Icons.keyboard
                                                : Icons.emoji_emotions,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8.0,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          onChanged: (value) => ref
                                              .read(chatControllerProvider
                                                  .notifier)
                                              .onTextChanged(value),
                                          controller: ref
                                              .read(chatControllerProvider)
                                              .messageController,
                                          focusNode: ref
                                              .read(
                                                  emojiPickerControllerProvider
                                                      .notifier)
                                              .fieldFocusNode,
                                          maxLines: 6,
                                          minLines: 1,
                                          cursorColor: colorTheme.greenColor,
                                          cursorHeight: 20,
                                          style: Theme.of(context)
                                              .custom
                                              .textTheme
                                              .bodyText1,
                                          decoration: InputDecoration(
                                            hintText: 'Message',
                                            hintStyle: Theme.of(context)
                                                .custom
                                                .textTheme
                                                .bodyText1
                                                .copyWith(),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8.0,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                onAttachmentsIconPressed(
                                                    context);
                                              },
                                              child: const Icon(
                                                Icons.attach_file_rounded,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                          if (!hideElements) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12.0,
                                                left: 16.0,
                                              ),
                                              child: InkWell(
                                                onTap: () {},
                                                child: CircleAvatar(
                                                  radius: 11,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? colorTheme.greyColor
                                                          : colorTheme
                                                              .iconColor,
                                                  child: Icon(
                                                    Icons.currency_rupee_sharp,
                                                    size: 14,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? colorTheme
                                                            .backgroundColor
                                                        : colorTheme
                                                            .appBarColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12.0,
                                                left: 16.0,
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  final image =
                                                      await capturePhoto();
                                                  if (image == null) return;
                                                  if (!mounted) return;
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AttachmentMessageSender(
                                                        attachments: [image],
                                                        attachmentTypes: const [
                                                          AttachmentType.image
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      )
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          StreamBuilder(
                                            stream: ref
                                                .read(chatControllerProvider)
                                                .soundRecorder
                                                .onProgress,
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Row(
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                      child: Icon(
                                                        Icons.mic,
                                                        color: Colors.red,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    Text(
                                                      "0:00",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: colorTheme
                                                            .iconColor,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }

                                              final duration =
                                                  snapshot.data!.duration;
                                              final showMic =
                                                  duration.inMilliseconds %
                                                          1000 >
                                                      500;
                                              return Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 12),
                                                    child: Icon(
                                                      Icons.mic,
                                                      color: showMic
                                                          ? Colors.red
                                                          : colorTheme
                                                              .appBarColor,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  Text(
                                                    strFormattedTime(
                                                      duration.inSeconds,
                                                      true,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          colorTheme.iconColor,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      Text(
                                        "◀ Slide to cancel",
                                        style: TextStyle(
                                          color: colorTheme.iconColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      hideElements
                          ? InkWell(
                              onTap: () async {
                                ref
                                    .read(chatControllerProvider.notifier)
                                    .onSendBtnPressed(
                                        ref, widget.self, widget.other);
                              },
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: colorTheme.greenColor,
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onLongPress: ref
                                  .read(chatControllerProvider.notifier)
                                  .onMicPressed,
                              onLongPressUp: () {
                                if (recordingState ==
                                    RecordingState.notRecording) {
                                  return;
                                }
                                ref
                                    .read(chatControllerProvider.notifier)
                                    .onRecordingDone();
                              },
                              onLongPressMoveUpdate: (details) async {
                                ref
                                    .read(chatControllerProvider.notifier)
                                    .onMicDragLeft(
                                      details.globalPosition.dx,
                                      MediaQuery.of(context).size.width,
                                    );

                                ref
                                    .read(chatControllerProvider.notifier)
                                    .onMicDragUp(
                                      details.globalPosition.dy,
                                      MediaQuery.of(context).size.height,
                                    );
                              },
                              child: recordingState ==
                                      RecordingState.notRecording
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundColor: colorTheme.greenColor,
                                      child: const Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: colorTheme.appBarColor,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                colorTheme.appBarColor,
                                            child: const Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                colorTheme.greenColor,
                                            child: const Icon(
                                              Icons.mic,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  color: colorTheme.appBarColor,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          StreamBuilder(
                            stream: ref
                                .read(chatControllerProvider)
                                .soundRecorder
                                .onProgress,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text(
                                  "0:00",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                );
                              }

                              final duration = snapshot.data!.duration;

                              return Text(
                                strFormattedTime(
                                  duration.inSeconds,
                                  true,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: colorTheme.iconColor,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              ref
                                  .read(chatControllerProvider.notifier)
                                  .cancelRecording();
                            },
                            child: const Icon(
                              Icons.delete_rounded,
                              size: 36,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (recordingState ==
                                  RecordingState.recordingLocked) {
                                ref
                                    .read(chatControllerProvider.notifier)
                                    .pauseRecording();
                              } else {
                                ref
                                    .read(chatControllerProvider.notifier)
                                    .resumeRecording();
                              }
                            },
                            child:
                                recordingState == RecordingState.recordingLocked
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.red),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.pause_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.mic,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                          ),
                          InkWell(
                            onTap: () async {
                              ref
                                  .read(chatControllerProvider.notifier)
                                  .onRecordingDone();
                            },
                            child: CircleAvatar(
                              radius: 21,
                              backgroundColor: colorTheme.greenColor,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
          if (ref
                  .read(emojiPickerControllerProvider.notifier)
                  .keyboardVisible ||
              showEmojiPicker == 1) ...[
            Stack(
              children: [
                SizedBox(
                  height: keyboardHeight,
                ),
                Offstage(
                  offstage: showEmojiPicker != 1,
                  child: CustomEmojiPicker(
                    afterEmojiPlaced: (emoji) => ref
                        .read(chatControllerProvider.notifier)
                        .onTextChanged(emoji.emoji),
                    textController:
                        ref.read(chatControllerProvider).messageController,
                  ),
                )
              ],
            )
          ],
        ],
      ),
    );
  }

  void onAttachmentsIconPressed(BuildContext context) {
    showDialog(
      barrierColor: null,
      context: context,
      builder: (context) {
        return Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: MediaQuery.of(context).size.height *
                (Platform.isIOS ? 0.54 : 0.4),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 18.0,
            ),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                LabelledButton(
                  onTap: () async {
                    final files = await pickFiles(
                      type: FileType.any,
                      allowCompression: false,
                      allowMultiple: true,
                    );
                    if (!mounted || files == null || files.isEmpty) return;
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentMessageSender(
                          attachments: files,
                          attachmentTypes: List.filled(
                            files.length,
                            AttachmentType.document,
                          ),
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.deepPurpleAccent,
                  label: 'Document',
                  child: const Icon(
                    Icons.insert_page_break,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                LabelledButton(
                  onTap: () async {
                    final image = await capturePhoto();
                    if (image == null) return;
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentMessageSender(
                          attachments: [image],
                          attachmentTypes: const [AttachmentType.image],
                        ),
                      ),
                    );
                  },
                  label: 'Camera',
                  backgroundColor: Colors.redAccent[400],
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                LabelledButton(
                  onTap: () async {
                    final media = await pickMultimedia();
                    if (media == null || media.isEmpty) return;
                    if (!mounted) return;

                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentMessageSender(
                          attachments: media,
                          attachmentTypes: media.map((e) {
                            AttachmentType? attachmentType;
                            final mimeType = lookupMimeType(e.path);

                            if (mimeType == null) {
                              return AttachmentType.document;
                            }

                            final type = mimeType.split("/")[0].toUpperCase();
                            if (['IMAGE', 'VIDEO'].contains(type)) {
                              attachmentType = AttachmentType.fromValue(type);
                            }

                            return attachmentType ?? AttachmentType.document;
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  label: 'Gallery',
                  backgroundColor: Colors.purple[400],
                  child: const Icon(
                    Icons.photo_size_select_actual_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                if (Platform.isAndroid) ...[
                  LabelledButton(
                    onTap: () async {
                      final files = await pickFiles(
                        type: FileType.audio,
                        allowMultiple: true,
                        allowCompression: false,
                      );
                      if (!mounted || files == null || files.isEmpty) return;
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AttachmentMessageSender(
                            attachments: files,
                            attachmentTypes: List.filled(
                              files.length,
                              AttachmentType.audio,
                            ),
                          ),
                        ),
                      );
                    },
                    label: 'Audio',
                    backgroundColor: Colors.orange[900],
                    child: const Icon(
                      Icons.headphones_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  )
                ],
                LabelledButton(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: 'Location',
                  backgroundColor: Colors.green[600],
                  child: const Icon(
                    Icons.location_on,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                LabelledButton(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: 'Payment',
                  backgroundColor: Colors.teal[600],
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.currency_rupee_rounded,
                      size: 18,
                      color: Colors.teal[600],
                    ),
                  ),
                ),
                LabelledButton(
                  onTap: () async {
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: 'Contact',
                  backgroundColor: Colors.blue[600],
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChatStream extends ConsumerStatefulWidget {
  const ChatStream({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends ConsumerState<ChatStream> {
  late final User self;
  late final User other;

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    other = ref.read(chatControllerProvider.notifier).other;
    super.initState();
  }

  void _sendUpdates(Message message) {
    ref
        .read(firebaseFirestoreRepositoryProvider)
        .updateMessage(message, {"status": "SEEN"});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref
          .read(firebaseFirestoreRepositoryProvider)
          .getChatStream(self.id, other.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final messages = snapshot.data!;
        for (var message in messages) {
          if (message.status == MessageStatus.seen) continue;
          if (message.senderId == self.id) continue;

          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _sendUpdates(message),
          );
        }

        return ListView.builder(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          itemCount: messages.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            Message message = messages[index];

            if (index == messages.length - 1 ||
                (messages[index].senderId != messages[index + 1].senderId)) {
              return message.senderId == self.id
                  ? MessageCard(
                      message: message,
                      special: true,
                      type: MessageCardType.sentMessageCard,
                    )
                  : MessageCard(
                      message: message,
                      special: true,
                      type: MessageCardType.receivedMessageCard,
                    );
            }

            return message.senderId == self.id
                ? MessageCard(
                    message: message,
                    type: MessageCardType.sentMessageCard,
                  )
                : MessageCard(
                    message: message,
                    type: MessageCardType.receivedMessageCard,
                  );
          },
        );
      },
    );
  }
}
