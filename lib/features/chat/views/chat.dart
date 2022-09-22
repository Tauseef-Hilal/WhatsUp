import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/emoji_picker.dart';
import 'package:whatsapp_clone/theme/colors.dart';

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

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    ref.read(chatControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final self = widget.self;
    final other = widget.other;
    final hideElements = ref.watch(chatControllerProvider);
    final showEmojiPicker = ref.watch(emojiPickerControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(other.avatarUrl),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  other.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 17.0),
                ),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 34.0,
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
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ChatStream(
                  self: self,
                  other: other,
                ),
              ),
            ),
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
                              padding: const EdgeInsets.only(bottom: 9.0),
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
                                  size: 28.0,
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
                                    .read(chatControllerProvider.notifier)
                                    .messageController,
                                focusNode: ref
                                    .read(
                                        emojiPickerControllerProvider.notifier)
                                    .fieldFocusNode,
                                maxLines: 6,
                                minLines: 1,
                                cursorColor: AppColors.tabColor,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Message',
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
                                    right: 8.0,
                                  ),
                                  child: InkWell(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.attach_file_rounded,
                                      size: 24.0,
                                      color: AppColors.iconColor,
                                    ),
                                  ),
                                ),
                                if (!hideElements) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                      right: 8.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: const CircleAvatar(
                                        radius: 11,
                                        backgroundColor: AppColors.iconColor,
                                        child: Icon(
                                          Icons.currency_rupee_sharp,
                                          size: 16,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 24.0,
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
                              .onSendBtnPressed(ref, self, other),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.tabColor,
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
                            backgroundColor: AppColors.tabColor,
                            child: Icon(
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
                .keyboardVisible)
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            Offstage(
              offstage: !showEmojiPicker,
              child: SizedBox(
                height: 0.72 * (MediaQuery.of(context).size.height / 2),
                child: CustomEmojiPicker(
                  afterEmojiPlaced: (emoji) => ref
                      .read(chatControllerProvider.notifier)
                      .onTextChanged(emoji.emoji),
                  textController: ref
                      .read(chatControllerProvider.notifier)
                      .messageController,
                ),
              ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
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
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          itemCount: messages.length,
          shrinkWrap: true,
          controller: _scrollController,
          itemBuilder: (context, index) {
            return messages[index].senderId == widget.self.id
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: AppColors.senderMessageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            messages[index].content,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(fontSize: 12),
                            softWrap: true,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            formattedTimestamp(
                              messages[index].timestamp,
                              true,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: AppColors.receiverMessageColor,
                      ),
                      margin: const EdgeInsets.only(bottom: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            messages[index].content,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(fontSize: 12),
                            softWrap: true,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            formattedTimestamp(
                              messages[index].timestamp,
                              true,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}
