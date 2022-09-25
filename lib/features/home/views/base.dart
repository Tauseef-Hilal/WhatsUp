import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/features/chat/models/message.dart';
import 'package:whatsapp_clone/features/chat/models/recent_chat.dart';
import 'package:whatsapp_clone/features/chat/views/chat.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/features/home/views/contacts.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/theme/theme.dart';
import '../../../theme/colors.dart';

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);

    // Exception needs to be handled for the case - Permission
    FlutterContacts.addListener(_contactsListener);

    _floatingButtons = [
      FloatingActionButton(
        onPressed: () async {
          if (!await ref.read(contactsRepositoryProvider).requestPermission()) {
            final prefs = await SharedPreferences.getInstance();

            if (prefs.getBool('showAppSettingsForContactsPerm') ?? false) {
              return AppSettings.openAppSettings(asAnotherTask: true);
            }

            prefs.setBool('showAppSettingsForContactsPerm', true);
            return;
          }

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
            backgroundColor: AppColors.appBarColor,
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'WhatsApp',
            style: Theme.of(context).custom.textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: AppColors.iconColor,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.iconColor,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.greenColor,
            indicatorWeight: 3.0,
            labelColor: AppColors.greenColor,
            labelStyle: Theme.of(context).custom.textTheme.labelLarge,
            unselectedLabelColor: AppColors.greyColor,
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
          children: [
            RecentChats(user: widget.user),
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

class RecentChats extends ConsumerStatefulWidget {
  const RecentChats({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  ConsumerState<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends ConsumerState<RecentChats> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecentChat>>(
        stream: ref
            .read(firebaseFirestoreRepositoryProvider)
            .getRecentChatStream(widget.user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final chats = snapshot.data!;
          return Padding(
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

                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          self: widget.user,
                          other: chat.user,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 24.0,
                    backgroundImage: NetworkImage(
                      chat.user.avatarUrl,
                    ),
                  ),
                  title: Text(
                    chat.user.name,
                    style: Theme.of(context).custom.textTheme.titleMedium,
                  ),
                  subtitle: Row(
                    children: [
                      if (msgStatus.isNotEmpty) ...[
                        Image.asset(
                          'assets/images/$msgStatus.png',
                          color: msgStatus != 'SEEN' ? Colors.white : null,
                          width: 15.0,
                        ),
                        const SizedBox(
                          width: 2.0,
                        )
                      ],
                      Text(
                          msgContent.length > 20
                              ? '${chat.message.content.substring(0, 20)}...'
                              : chat.message.content,
                          style: Theme.of(context).custom.textTheme.subtitle2)
                    ],
                  ),
                  trailing: Text(formattedTimestamp(chat.message.timestamp),
                      style: Theme.of(context).custom.textTheme.caption),
                );
              },
            ),
          );
        });
  }
}
