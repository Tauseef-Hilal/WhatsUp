import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/attachment_picker.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/chat_date.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/chat_field.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/chat_mic.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/message_cards.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/scroll_btn.dart';
import 'package:whatsapp_clone/features/chat/views/widgets/voice_recorder.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/utils/shared_pref.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_inset.dart';
import 'package:whatsapp_clone/theme/color_theme.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/widgets/emoji_picker.dart';
import 'widgets/unread_banner.dart';

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
        .initUsers(widget.self, widget.other, widget.otherUserContactName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final self = widget.self;
    final other = widget.other;

    return Platform.isAndroid
        ? PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (!ref.read(chatControllerProvider).showEmojiPicker) {
                Navigator.pop(context);
                return;
              }

              ref
                  .read(chatControllerProvider.notifier)
                  .setShowEmojiPicker(false);
            },
            child: _build(self, other, context),
          )
        : _build(self, other, context);
  }

  Widget _build(User self, User other, BuildContext context) {
    final recordingState = ref.watch(
      chatControllerProvider.select((chatState) => chatState.recordingState),
    );

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
        leadingWidth: 36.0,
        leading: IconButton(
          onPressed: () =>
              ref.read(chatControllerProvider.notifier).navigateToHome(context),
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                recordingState == RecordingState.notRecording ? () {} : null,
            icon: const Icon(
              Icons.videocam_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed:
                recordingState == RecordingState.notRecording ? () {} : null,
            icon: const Icon(
              Icons.call,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Theme.of(context).themedImage('chat_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Platform.isIOS
                  ? GestureDetector(
                      onTap: () {
                        SystemChannels.textInput.invokeMethod(
                          "TextInput.hide",
                        );
                        ref
                            .read(chatControllerProvider.notifier)
                            .setShowEmojiPicker(false);
                      },
                      child: const ChatStream(),
                    )
                  : const ChatStream(),
            ),
            const SizedBox(
              height: 4.0,
            ),
            ChatInputContainer(
              self: self,
              other: other,
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

class _ChatInputContainerState extends ConsumerState<ChatInputContainer>
    with WidgetsBindingObserver {
  double keyboardHeight = SharedPref.instance.getDouble('keyboardHeight')!;
  bool isKeyboardVisible = false;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    ref.read(chatControllerProvider.notifier).initRecorder();
    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((isVisible) async {
      isKeyboardVisible = isVisible;
      if (isVisible) {
        ref.read(chatControllerProvider.notifier).setShowEmojiPicker(false);
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _keyboardSubscription.cancel();
  }

  void switchKeyboards() async {
    final showEmojiPicker = ref.read(chatControllerProvider).showEmojiPicker;

    if (!showEmojiPicker && !isKeyboardVisible) {
      ref.read(chatControllerProvider.notifier).setShowEmojiPicker(true);
    } else if (showEmojiPicker) {
      ref.read(chatControllerProvider).fieldFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || showEmojiPicker) return;
        ref.read(chatControllerProvider.notifier).setShowEmojiPicker(false);
      });
    } else if (isKeyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      ref.read(chatControllerProvider.notifier).setShowEmojiPicker(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final hideElements = ref.watch(
      chatControllerProvider.select((s) => s.hideElements),
    );
    final recordingState = ref.watch(
      chatControllerProvider.select((s) => s.recordingState),
    );
    final showEmojiPicker = ref.watch(
      chatControllerProvider.select((s) => s.showEmojiPicker),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.light
                ? colorTheme.greyColor
                : colorTheme.iconColor),
      ),
      child: AvoidBottomInset(
        padding: EdgeInsets.only(bottom: Platform.isAndroid ? 4.0 : 24.0),
        conditions: [showEmojiPicker],
        offstage: Offstage(
          offstage: !showEmojiPicker,
          child: CustomEmojiPicker(
            afterEmojiPlaced: (emoji) => ref
                .read(chatControllerProvider.notifier)
                .onTextChanged(emoji.emoji),
            textController: ref.read(chatControllerProvider).messageController,
          ),
        ),
        child: recordingState != RecordingState.recordingLocked &&
                recordingState != RecordingState.paused
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.appBarColor
                              : colorTheme.backgroundColor,
                        ),
                        child: recordingState == RecordingState.notRecording
                            ? _buildChatField(
                                showEmojiPicker,
                                context,
                                hideElements,
                                colorTheme,
                              )
                            : const VoiceRecorderField(),
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
                                    ref,
                                    widget.self,
                                    widget.other,
                                  );
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
                        : const ChatInputMic(),
                  ],
                ),
              )
            : const VoiceRecorder(),
      ),
    );
  }

  ChatField _buildChatField(bool showEmojiPicker, BuildContext context,
      bool hideElements, ColorTheme colorTheme) {
    return ChatField(
        leading: GestureDetector(
          onTap: switchKeyboards,
          child: Icon(
            !showEmojiPicker ? Icons.emoji_emotions : Icons.keyboard,
            size: 26.0,
          ),
        ),
        focusNode: ref.read(chatControllerProvider).fieldFocusNode,
        onTextChanged: (value) =>
            ref.read(chatControllerProvider.notifier).onTextChanged(value),
        textController: ref.read(chatControllerProvider).messageController,
        actions: [
          InkWell(
            onTap: () {
              onAttachmentsIconPressed(
                context,
              );
            },
            child: Transform.rotate(
              angle: -0.8,
              child: const Icon(
                Icons.attach_file_rounded,
                size: 26.0,
              ),
            ),
          ),
          if (!hideElements) ...[
            InkWell(
              onTap: () {},
              child: Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.light
                      ? colorTheme.greyColor
                      : colorTheme.iconColor,
                ),
                child: Center(
                  child: Text(
                    '₹',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? colorTheme.backgroundColor
                          : colorTheme.appBarColor,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                ref
                    .read(
                      chatControllerProvider.notifier,
                    )
                    .navigateToCameraView(context);
              },
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 24.0,
              ),
            ),
          ],
        ]);
  }

  void onAttachmentsIconPressed(BuildContext context) {
    final focusNode = ref.read(chatControllerProvider).fieldFocusNode;
    focusNode.unfocus();
    Future.delayed(
      Duration(
        milliseconds: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0,
      ),
      () async {
        if (!mounted) return;
        showDialog(
          barrierColor: null,
          context: context,
          builder: (context) {
            return Dialog(
              alignment: Alignment.bottomCenter,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: ref.read(chatControllerProvider).showEmojiPicker
                    ? 36.0
                    : 56.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: AttachmentPicker(),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatStream extends ConsumerStatefulWidget {
  const ChatStream({
    super.key,
  });

  @override
  ConsumerState<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends ConsumerState<ChatStream> {
  late final User self;
  late final User other;
  late final String chatId;
  late final ScrollController scrollController;
  late Stream<List<Message>> messageStream;

  bool isInitialRender = true;
  int unreadCount = 0;
  int prevMsgCount = 0;
  final bannerKey = GlobalKey();

  @override
  void initState() {
    self = ref.read(chatControllerProvider.notifier).self;
    other = ref.read(chatControllerProvider.notifier).other;
    chatId = getChatId(self.id, other.id);

    messageStream = IsarDb.getChatStream(chatId);
    scrollController = ScrollController();

    super.initState();
  }

  @override
  void dispose() async {
    scrollController.dispose();
    super.dispose();
  }

  void handleNewMessage(Message message) {
    if (message.senderId == self.id) {
      unreadCount = 0;
      if (message.status == MessageStatus.pending) {
        scrollToBottom();
      }
    } else {
      unreadCount = unreadCount > 0 ? unreadCount + 1 : 0;
    }
  }

  void handleInitialData(int unreadMsgCount) {
    isInitialRender = false;
    unreadCount = unreadMsgCount;

    if (unreadCount > 0) {
      scrollToUnreadBanner();
    }
  }

  int updateUnreadCount(List<Message> messages) {
    int unreadCount = 0;

    for (final message in messages) {
      if (message.senderId == self.id) break;
      if (message.status == MessageStatus.seen) break;
      unreadCount++;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).setUnreadCount(unreadCount);
    });

    return unreadCount;
  }

  void scrollToUnreadBanner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Scrollable.ensureVisible(
        bannerKey.currentContext!,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void markAsSeen(Message message) {
    if (message.senderId == self.id) return;
    if (message.status == MessageStatus.seen) return;
    ref.read(chatControllerProvider.notifier).markMessageAsSeen(message);
  }

  int getMessageIndexByKey(Key key, List<Message> messages) {
    final messageKey = key as ValueKey;
    return messages.indexWhere((msg) => msg.id == messageKey.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = Theme.of(context).custom.colorTheme;

    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final messages = snapshot.data!;
        final unreadMsgCount = updateUnreadCount(messages);

        if (isInitialRender) {
          handleInitialData(unreadMsgCount);
        } else if (messages.length - prevMsgCount > 0) {
          handleNewMessage(messages.first);
        }

        prevMsgCount = messages.length;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(color: Colors.transparent),
            CustomScrollView(
              shrinkWrap: true,
              reverse: true,
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (unreadCount > 0) ...[
                  SliverList.builder(
                    itemCount: unreadCount,
                    itemBuilder: (context, index) {
                      return buildMessageCard(index, messages);
                    },
                    findChildIndexCallback: (key) {
                      return getMessageIndexByKey(key, messages);
                    },
                  ),
                  SliverToBoxAdapter(
                    key: bannerKey,
                    child: UnreadMessagesBanner(
                      unreadCount: unreadCount,
                    ),
                  ),
                ],
                SliverList.builder(
                  itemCount: messages.length - unreadCount,
                  itemBuilder: (context, index) {
                    index = index + unreadCount;
                    return buildMessageCard(index, messages);
                  },
                  findChildIndexCallback: (key) {
                    return getMessageIndexByKey(key, messages);
                  },
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkTheme
                            ? const Color.fromARGB(200, 24, 34, 40)
                            : const Color.fromARGB(148, 248, 236, 130),
                      ),
                      child: Text(
                        '🔒Messages and calls are end-to-end encrypted. No one outside this chat, not even WhatsApp, can read or listen to them. Tap to learn more.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkTheme
                              ? colorTheme.yellowColor
                              : colorTheme.textColor1,
                        ),
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.longestLine,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ChatDate(
                      date: messages.isEmpty
                          ? 'Today'
                          : dateFromTimestamp(messages.last.timestamp),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ScrollButton(scrollController: scrollController),
            )
          ],
        );
      },
    );
  }

  Widget buildMessageCard(int index, List<Message> messages) {
    final message = messages[index];
    final isFirstMsg = index == messages.length - 1;
    final isSpecial =
        isFirstMsg || messages[index].senderId != messages[index + 1].senderId;
    final currMsgDate = dateFromTimestamp(messages[index].timestamp);
    final showDate = isFirstMsg ||
        currMsgDate != dateFromTimestamp(messages[index + 1].timestamp);

    return Column(
      key: ValueKey(message.id),
      children: [
        if (!isFirstMsg && showDate) ...[
          ChatDate(date: currMsgDate),
        ],
        VisibilityDetector(
          key: ValueKey('${message.id}_vd'),
          onVisibilityChanged: (info) {
            if (info.visibleFraction < 0.1) return;
            markAsSeen(message);
          },
          child: MessageCard(
            message: message,
            currentUserId: self.id,
            special: isSpecial,
          ),
        ),
      ],
    );
  }
}
