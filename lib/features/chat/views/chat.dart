import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/buttons.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/message_cards.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_storage.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/theme.dart';

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

class _ChatPageState extends ConsumerState<ChatPage>
    with WidgetsBindingObserver {
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChatStream(
                  self: self,
                  other: other,
                ),
              ),
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

class AttachmentWidget extends ConsumerStatefulWidget {
  const AttachmentWidget({
    super.key,
    required this.attachments,
    required this.self,
    required this.other,
  });

  final List<File> attachments;
  final User self;
  final User other;

  @override
  ConsumerState<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends ConsumerState<AttachmentWidget> {
  late File current;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    controllers =
        widget.attachments.map((_) => TextEditingController()).toList();
    current = widget.attachments[0];
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorTheme.backgroundColor,
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: colorTheme.iconColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      child: Icon(Icons.close),
                    ),
                  ),
                  trailing: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.crop),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.sticky_note_2),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.text_format_outlined),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(100, 0, 0, 0),
                        child: Icon(Icons.draw),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Image.file(
                    current,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.attachments.map(
                      (file) {
                        return GestureDetector(
                            onTap: () {
                              setState(() {
                                current = file;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Image.file(file, height: 50),
                            ));
                      },
                    ).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24.0),
                            ),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorTheme.appBarColor
                                    : colorTheme.backgroundColor,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: ref
                                        .read(emojiPickerControllerProvider
                                            .notifier)
                                        .toggleEmojiPicker,
                                    child: const Icon(
                                      Icons.add,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: controllers[
                                        widget.attachments.indexOf(current)],
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      InkWell(
                        onTap: () async {
                          for (var i = 0; i < controllers.length; i++) {
                            final controller = controllers[i];
                            final attachedFile = widget.attachments[i];

                            MessageStatus status = MessageStatus.sent;
                            String messageId = const Uuid().v4();

                            // if (!await isConnected()) {
                            //   status = MessageStatus.pending;
                            // }
                            final fileName = attachedFile.path.split("/").last;
                            final url = await ref
                                .read(firebaseStorageRepoProvider)
                                .uploadFileToFirebase(
                                  attachedFile,
                                  "attachments/${messageId}__$fileName",
                                );

                            final msg = Message(
                              id: messageId,
                              content: controller.text.trim(),
                              status: status,
                              senderId: widget.self.id,
                              receiverId: widget.other.id,
                              timestamp: Timestamp.now(),
                              attachment: Attachment(
                                type: AttachmentType.document,
                                url: url,
                                fileName:
                                    "${messageId}__${attachedFile.path.split("/").last}",
                                fileSize: "",
                              ),
                            );

                            ref
                                .read(firebaseFirestoreRepositoryProvider)
                                .sendMessage(msg, widget.self, widget.other);
                          }

                          if (!mounted) return;
                          Navigator.of(context).pop();
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
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    ref
        .read(emojiPickerControllerProvider.notifier)
        .init(keyboardVisibility: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final hideElements = ref.watch(chatControllerProvider).hideElements;
    final showEmojiPicker = ref.watch(emojiPickerControllerProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.light
                ? colorTheme.greyColor
                : colorTheme.iconColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(24.0),
                      ),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colorTheme.appBarColor
                          : colorTheme.backgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: ref
                                  .read(emojiPickerControllerProvider.notifier)
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
                              onChanged: (value) => ref
                                  .read(chatControllerProvider.notifier)
                                  .onTextChanged(value),
                              controller: ref
                                  .read(chatControllerProvider)
                                  .messageController,
                              focusNode: ref
                                  .read(emojiPickerControllerProvider.notifier)
                                  .fieldFocusNode,
                              maxLines: 6,
                              minLines: 1,
                              cursorColor: colorTheme.greenColor,
                              cursorHeight: 20,
                              style:
                                  Theme.of(context).custom.textTheme.bodyText1,
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
                                    onAttachmentsIconPressed(context);
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
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? colorTheme.greyColor
                                              : colorTheme.iconColor,
                                      child: Icon(
                                        Icons.currency_rupee_sharp,
                                        size: 14,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? colorTheme.backgroundColor
                                            : colorTheme.appBarColor,
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
                                      await capturePhoto();
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
                hideElements
                    ? InkWell(
                        onTap: () => ref
                            .read(chatControllerProvider.notifier)
                            .onSendBtnPressed(ref, widget.self, widget.other),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: colorTheme.greenColor,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: colorTheme.greenColor,
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          insetPadding: EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: MediaQuery.of(context).size.height * 0.4,
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
                    await pickFile();
                    if (!mounted) return;
                    Navigator.pop(context);
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
                    await capturePhoto();
                    if (!mounted) return;
                    Navigator.pop(context);
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
                    final images = await pickImagesFromGallery();
                    if (images == null) return;
                    if (!mounted) return;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttachmentWidget(
                          attachments: images,
                          self: widget.self,
                          other: widget.other,
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
                LabelledButton(
                  onTap: () async {
                    await pickFile(FileType.audio);
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: 'Audio',
                  backgroundColor: Colors.orange[900],
                  child: const Icon(
                    Icons.headphones_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
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
                    await pickContact();

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
    required this.self,
    required this.other,
  }) : super(key: key);

  final User self;
  final User other;

  @override
  ConsumerState<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends ConsumerState<ChatStream> {

  void _sendUpdates(Message message) {
    ref
        .read(firebaseFirestoreRepositoryProvider)
        .sendMessage(message, widget.self, widget.other);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref
          .read(firebaseFirestoreRepositoryProvider)
          .getChatStream(widget.self.id, widget.other.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final messages = snapshot.data!;
        for (var message in messages) {
          if (message.status == MessageStatus.seen) continue;

          if (message.senderId == widget.self.id) {
            if (message.status == MessageStatus.pending) {
              // ...
            }

            continue;
          }

          message.status = MessageStatus.seen;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _sendUpdates(message),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              reverse: true,
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Message message = messages[index];
                String msgStatus = message.status.value;

                if (index == messages.length - 1 ||
                    (messages[index].senderId !=
                        messages[index + 1].senderId)) {
                  return message.senderId == widget.self.id
                      ? SentMessageCard(
                          message: message,
                          msgStatus: msgStatus,
                          special: true,
                        )
                      : ReceivedMessageCard(
                          message: message,
                          special: true,
                        );
                }

                return message.senderId == widget.self.id
                    ? SentMessageCard(message: message, msgStatus: msgStatus)
                    : ReceivedMessageCard(message: message);
              },
            ),
            // if (showScrollBtn) ...[
            //   Positioned(
            //     bottom: 2.0,
            //     right: 2.0,
            //     child: GestureDetector(
            //       onTap: () {},
            //       child: CircleAvatar(
            //         backgroundColor:
            //             Theme.of(context).custom.colorTheme.appBarColor,
            //         child: const Icon(Icons.keyboard_double_arrow_down),
            //       ),
            //     ),
            //   )
            // ],
          ],
        );
      },
    );
  }
}
