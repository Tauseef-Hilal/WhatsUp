import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/colors.dart';
import 'package:whatsapp_clone/theme/dark.dart';

class ChatPage extends ConsumerStatefulWidget {
  final User self;
  final User other;

  const ChatPage({
    super.key,
    required this.self,
    required this.other,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    ref.read(chatInputControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final self = widget.self;
    final other = widget.other;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  other.name,
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
        leadingWidth: 30.0,
        leading: IconButton(
          onPressed: () => ref
              .read(chatInputControllerProvider.notifier)
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
              image: Theme.of(context).imageForName('chat_bg_dark.png'),
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
            ChatInput(
              self: self,
              other: other,
            ),
            const SizedBox(
              height: 8.0,
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
  @override
  Widget build(BuildContext context) {
    final hideElements = ref.watch(chatInputControllerProvider);
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
                              showEmojiPicker
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
                                .read(chatInputControllerProvider.notifier)
                                .onTextChanged(value),
                            controller: ref
                                .read(chatInputControllerProvider.notifier)
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
                                onTap: () {},
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
                          .read(chatInputControllerProvider.notifier)
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
        Offstage(
          offstage: !showEmojiPicker,
          child: SizedBox(
            height: 0.70 * (MediaQuery.of(context).size.height / 2),
            child: CustomEmojiPicker(
              afterEmojiPlaced: (emoji) => ref
                  .read(chatInputControllerProvider.notifier)
                  .onTextChanged(emoji.emoji),
              textController: ref
                  .read(chatInputControllerProvider.notifier)
                  .messageController,
            ),
          ),
        )
      ],
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

class ReceivedMessageCard extends StatelessWidget {
  const ReceivedMessageCard({
    Key? key,
    required this.message,
    this.special = false,
  }) : super(key: key);

  final Message message;
  final bool special;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 32,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppColors.incomingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: special ? 6.0 : 0),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Stack(
          children: [
            Text(
              message.content + ' ' * 12,
              style: Theme.of(context).custom.textTheme.bodyText1,
              softWrap: true,
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: Row(
                children: [
                  Text(
                    formattedTimestamp(
                      message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: AppColors.textColor2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SentMessageCard extends StatelessWidget {
  const SentMessageCard({
    Key? key,
    required this.message,
    required this.msgStatus,
    this.special = false,
  }) : super(key: key);

  final Message message;
  final String msgStatus;
  final bool special;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 32,
          minWidth: 80,
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColors.outgoingMessageBubbleColor,
        ),
        margin: EdgeInsets.only(bottom: 2.0, top: special ? 6.0 : 0.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Stack(
          children: [
            Text(
              message.content + ' ' * 16,
              style: Theme.of(context).custom.textTheme.bodyText1,
              softWrap: true,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTimestamp(
                      message.timestamp,
                      true,
                    ),
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11, color: AppColors.textColor2),
                  ),
                  const SizedBox(
                    width: 2.0,
                  ),
                  Image.asset(
                    'assets/images/$msgStatus.png',
                    color: msgStatus != 'SEEN' ? Colors.white : null,
                    width: 15.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
