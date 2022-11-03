import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/buttons.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/message_cards.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/colors.dart';
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
              backgroundImage: NetworkImage(other.avatarUrl),
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
                            style: Theme.of(context).textTheme.caption,
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
          onPressed: () =>
              ref.read(chatControllerProvider).navigateToHome(context, self),
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
            ChatInput(
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

class ChatInput extends ConsumerStatefulWidget {
  const ChatInput({super.key, required this.self, required this.other});

  final User self;
  final User other;

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  late final double keyboardHeight;

  @override
  void initState() {
    keyboardHeight = ref.read(keyboardHeightProvider.notifier).state;
    ref
        .read(emojiPickerControllerProvider.notifier)
        .init(keyboardVisibility: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hideElements = ref.watch(chatControllerProvider).hideElements;
    final showEmojiPicker = ref.watch(emojiPickerControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                    color: AppColors.appBarColor,
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
                                .read(
                                  emojiPickerControllerProvider.notifier,
                                )
                                .toggleEmojiPicker,
                            child: Icon(
                              showEmojiPicker == 1
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions,
                              size: 24.0,
                              color: AppColors.iconColor,
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
                            cursorColor: AppColors.greenColor,
                            cursorHeight: 20,
                            style: Theme.of(context).custom.textTheme.bodyText1,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: Theme.of(context)
                                  .custom
                                  .textTheme
                                  .bodyText1
                                  .copyWith(color: AppColors.iconColor),
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
                                  color: AppColors.iconColor,
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
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.iconColor,
                                    child: Icon(
                                      Icons.currency_rupee_sharp,
                                      size: 14,
                                      color: Colors.black,
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
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 22.0,
                                    color: AppColors.iconColor,
                                  ),
                                ),
                              ),
                            ]
                          ],
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
                      onTap: () => ref
                          .read(chatControllerProvider.notifier)
                          .onSendBtnPressed(ref, widget.self, widget.other),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.greenColor,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {},
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.greenColor,
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        if (ref.read(emojiPickerControllerProvider.notifier).keyboardVisible ||
            showEmojiPicker == 1) ...[
          Stack(
            children: [
              SizedBox(
                height: Platform.isIOS ? keyboardHeight + 38.0 : keyboardHeight,
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
    );
  }

  void onAttachmentsIconPressed(BuildContext context) {
    showDialog(
      barrierColor: null,
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          backgroundColor: AppColors.appBarColor,
          insetPadding: EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: MediaQuery.of(context).size.height - 500,
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                LabelledButton(
                  onTap: () async {
                    if (!await hasPermission(Permission.storage)) return;
                    await pickFile();
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
                  onTap: () {},
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
                    if (!await hasPermission(Permission.storage)) return;
                    await pickImageFromGallery();
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
                    if (!await hasPermission(Permission.storage)) return;
                    await pickFile(FileType.audio);
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
                  onTap: () {},
                  label: 'Location',
                  backgroundColor: Colors.green[600],
                  child: const Icon(
                    Icons.location_on,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                LabelledButton(
                  onTap: () {},
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
                  onTap: () {},
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
  final _scrollController = ScrollController();
  bool initialScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (initialScroll) {
      // Not the right way ig
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 50);
      initialScroll = false;
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

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
              message.status = MessageStatus.sent;
            }

            continue;
          }

          message.status = MessageStatus.seen;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _sendUpdates(message),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: messages.length,
          shrinkWrap: true,
          controller: _scrollController,
          itemBuilder: (context, index) {
            Message message = messages[index];
            String msgStatus = message.status.value;

            if (index == 0 ||
                messages[index - 1].senderId != messages[index].senderId) {
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
        );
      },
    );
  }
}
