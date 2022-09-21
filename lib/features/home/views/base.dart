import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/features/home/views/contacts.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import '../../../theme/colors.dart';

class HomePage extends ConsumerStatefulWidget {
  final String userId;

  const HomePage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Widget> _floatingButtons;
  late final User user;

  @override
  void initState() {
    super.initState();
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
            MaterialPageRoute(builder: (context) => const ContactsPage()),
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
  }

  void _contactsListener() {
    ref.refresh(contactsRepositoryProvider);
  }

  @override
  void dispose() {
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
          title: const Text('WhatsApp'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.tabColor,
            indicatorWeight: 3.0,
            labelColor: AppColors.tabColor,
            unselectedLabelColor: AppColors.textColor,
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
          children: const [
            Center(
              child: Text('Coming soon'),
            ),
            Center(
              child: Text('Coming soon'),
            ),
            Center(
              child: Text('Coming soon'),
            )
          ],
        ),
        floatingActionButton: _floatingButtons[_tabController.index],
      ),
    );
  }
}
