import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/features/chat/models/attachement.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
import 'package:whatsapp_clone/features/chat/views/chat.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/features/home/views/contacts.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import '../../../theme/color_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  final User user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late List<Widget> _floatingButtons;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(firebaseFirestoreRepositoryProvider).setActivityStatus(
            userId: widget.user.id,
            statusValue: UserActivityStatus.online.value);
        break;
      default:
        ref.read(firebaseFirestoreRepositoryProvider).setActivityStatus(
            userId: widget.user.id,
            statusValue: UserActivityStatus.offline.value);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> addListenerToContactChanges() async {
    if (await Permission.contacts.isGranted) {
      FlutterContacts.addListener(_contactsListener);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);

    // Add listener to contact data changes
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await addListenerToContactChanges();
    });

    _floatingButtons = [
      FloatingActionButton(
        onPressed: () async {
          if (!await hasPermission(Permission.contacts)) return;
          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContactsPage(
                user: widget.user,
              ),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColorsDark.appBarColor,
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          const SizedBox(
            height: 16.0,
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
      FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_call),
      )
    ];

    super.initState();
  }

  void _contactsListener() {
    // ignore: unused_result
    ref.refresh(contactsRepositoryProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterContacts.removeListener(_contactsListener);
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).custom.textTheme;
    final colorTheme = Theme.of(context).custom.colorTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'WhatsApp',
            style: textTheme.titleLarge.copyWith(color: colorTheme.iconColor),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colorTheme.indicatorColor,
            indicatorWeight: 3.0,
            labelColor: colorTheme.selectedLabelColor,
            labelStyle: textTheme.labelLarge,
            unselectedLabelColor: colorTheme.unselectedLabelColor,
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            RecentChatsBody(user: widget.user),
            const Center(
              child: Text('Coming soon'),
            ),
            const Center(
              child: Text('Coming soon'),
            )
          ],
        ),
        floatingActionButton: _floatingButtons[_tabController.index],
      ),
    );
  }
}

class RecentChatsBody extends ConsumerStatefulWidget {
  const RecentChatsBody({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  ConsumerState<RecentChatsBody> createState() => _RecentChatsBodyState();
}

class _RecentChatsBodyState extends ConsumerState<RecentChatsBody> {
  late final StreamSubscription<List<Message>> listener;

  @override
  void initState() {
    final firestore = ref.read(firebaseFirestoreRepositoryProvider);
    listener = firestore.getChatStream(widget.user.id).listen((messages) async {
      for (final message in messages) {
        if (message.type == MessageType.replacementMessage) {
          await IsarDb.updateMessage(message.id, message);
          continue;
        }

        await IsarDb.addMessage(message..status = MessageStatus.delivered);
        await firestore.sendReplacementMessage(
          message: message.copyWith(type: MessageType.replacementMessage),
          receiverId: message.senderId,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;

    return StreamBuilder<List<RecentChat>>(
        stream: IsarDb.getRecentChatStream(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          return RecentChats(
            chats: snapshot.data!,
            widget: widget,
            ref: ref,
            colorTheme: colorTheme,
          );
        });
  }
}

class RecentChats extends StatelessWidget {
  const RecentChats({
    super.key,
    required this.chats,
    required this.widget,
    required this.ref,
    required this.colorTheme,
  });

  final List<RecentChat> chats;
  final RecentChatsBody widget;
  final WidgetRef ref;
  final ColorTheme colorTheme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.builder(
            itemCount: chats.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              RecentChat chat = chats[index];
              Message msg = chat.message;
              String msgContent = chat.message.content;
              String msgStatus = '';

              if (msg.senderId == widget.user.id) {
                msgStatus = msg.status.value;
              }
              return RecentChatWidget(
                widget: widget,
                chat: chat,
                colorTheme: colorTheme,
                title: chat.user.name,
                msgStatus: msgStatus,
                msgContent: msgContent,
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 18,
                color: Theme.of(context).brightness == Brightness.light
                    ? colorTheme.greyColor
                    : colorTheme.iconColor,
              ),
              const SizedBox(width: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: 'Your personal messages are ',
                      style: TextStyle(color: colorTheme.greyColor),
                    ),
                    TextSpan(
                      text: 'end-to-end encrypted',
                      style: TextStyle(color: colorTheme.greenColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecentChatWidget extends StatelessWidget {
  const RecentChatWidget({
    super.key,
    required this.widget,
    required this.chat,
    required this.colorTheme,
    required this.title,
    required this.msgStatus,
    required this.msgContent,
  });

  final RecentChatsBody widget;
  final RecentChat chat;
  final ColorTheme colorTheme;
  final String title;
  final String msgStatus;
  final String msgContent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        chat.isNewForUser = false;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              self: widget.user,
              other: chat.user,
              otherUserContactName: title,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(
          chat.user.avatarUrl,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .custom
            .textTheme
            .titleMedium
            .copyWith(color: colorTheme.textColor1),
      ),
      subtitle: Row(
        children: [
          if (msgStatus.isNotEmpty) ...[
            Image.asset(
              'assets/images/$msgStatus.png',
              color: msgStatus != 'SEEN' ? colorTheme.textColor1 : null,
              width: 15.0,
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          if (chat.message.attachment != null) ...[
            LayoutBuilder(
              builder: (context, _) {
                switch (chat.message.attachment!.type) {
                  case AttachmentType.audio:
                    return const Icon(
                      Icons.audiotrack_rounded,
                      size: 20,
                    );

                  case AttachmentType.voice:
                    return const Icon(
                      Icons.mic,
                      size: 20,
                    );

                  case AttachmentType.image:
                    return const Icon(
                      Icons.image_rounded,
                      size: 20,
                    );

                  case AttachmentType.video:
                    return const Icon(
                      Icons.videocam_rounded,
                      size: 20,
                    );

                  default:
                    return const Icon(
                      Icons.file_copy,
                      size: 20,
                    );
                }
              },
            ),
            const SizedBox(
              width: 2.0,
            )
          ],
          Text(
              msgContent.length > 20
                  ? '${msgContent.substring(0, 20)}...'
                  : msgContent == "\u00A0" || msgContent.isEmpty
                      ? chat.message.attachment!.type.value
                      : msgContent,
              style: Theme.of(context).custom.textTheme.subtitle2)
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedTimestamp(
              chat.message.timestamp,
            ),
            style: Theme.of(context).custom.textTheme.caption.copyWith(
                  color: chat.isNewForUser
                      ? colorTheme.greenColor
                      : Theme.of(context).custom.colorTheme.greyColor,
                ),
          ),
          if (chat.isNewForUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.circle,
                color: colorTheme.greenColor,
              ),
            )
          ],
        ],
      ),
    );
  }
}
