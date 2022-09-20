import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/home/controllers/contacts_controller.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/shared/widgets/search.dart';
import 'package:whatsapp_clone/theme/colors.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _CountryPageState();
}

class _CountryPageState extends ConsumerState<ContactsPage> {
  bool _showLoadingIndicator = false;
  Timer? _timer;

  @override
  void initState() {
    ref.read(contactPickerControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(contactPickerControllerProvider);
    final contactsOnWhatsApp = searchResults['onWhatsApp']!;
    final contactsNotOnWhatsApp = searchResults['notOnWhatsApp']!;

    String searchQuery = ref
        .read(contactPickerControllerProvider.notifier)
        .searchController
        .text;

    bool buildWhatsAppContactsList = contactsOnWhatsApp.isNotEmpty;
    bool buildLocalContactsList = contactsNotOnWhatsApp.isNotEmpty;

    if (_showLoadingIndicator) {
      Timer(const Duration(microseconds: 500), () {
        _showLoadingIndicator = false;
      });
    }

    return ScaffoldWithSearch(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Select contact'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _showLoadingIndicator
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.tabColor,
                  ),
                )
              : const Text(''),
          PopupMenuButton(
            onSelected: (value) {},
            color: AppColors.appBarColor,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                  onTap: () => ref
                      .read(contactPickerControllerProvider.notifier)
                      .shareInviteLink(
                        context.findRenderObject() as RenderBox?,
                      ),
                  child: Text(
                    'Invite a friend',
                    style: Theme.of(context).textTheme.bodyText2,
                  )),
              PopupMenuItem(
                  onTap: ref
                      .read(contactPickerControllerProvider.notifier)
                      .openContacts,
                  child: Text(
                    'Contacts',
                    style: Theme.of(context).textTheme.bodyText2,
                  )),
              PopupMenuItem(
                  onTap: () {
                    if (_timer?.isActive ?? false) return;

                    setState(() {
                      _showLoadingIndicator = true;
                    });

                    ref
                        .read(contactPickerControllerProvider.notifier)
                        .refreshContactsList();
                  },
                  child: Text(
                    'Refresh',
                    style: Theme.of(context).textTheme.bodyText2,
                  )),
              PopupMenuItem(
                  onTap: ref
                      .read(contactPickerControllerProvider.notifier)
                      .showHelp,
                  child: Text(
                    'Help',
                    style: Theme.of(context).textTheme.bodyText2,
                  )),
            ],
          ),
        ],
      ),
      searchController:
          ref.read(contactPickerControllerProvider.notifier).searchController,
      onChanged: (value) => ref
          .read(contactPickerControllerProvider.notifier)
          .updateSearchResults(value),
      onCloseBtnPressed:
          ref.read(contactPickerControllerProvider.notifier).onCloseBtnPressed,
      searchIconActionIndex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            if (!buildWhatsAppContactsList &&
                !buildLocalContactsList &&
                searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No results found for \'${searchQuery.trim()}\'',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            if (searchQuery.isEmpty)
              Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: AppColors.tabColor,
                            child: Icon(
                              Icons.people,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 18.0,
                          ),
                          Text(
                            'New group',
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: ref
                        .read(contactPickerControllerProvider.notifier)
                        .createNewContact,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: AppColors.tabColor,
                            child: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 18.0,
                          ),
                          Text(
                            'New contact',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            if (contactsOnWhatsApp.isNotEmpty)
              ..._buildWhatsAppContactsList(context, contactsOnWhatsApp),
            if (contactsNotOnWhatsApp.isNotEmpty)
              ..._buildLocalContactsList(context, contactsNotOnWhatsApp),
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  'More',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            Column(
              children: [
                if (searchQuery.isNotEmpty)
                  InkWell(
                    onTap: ref
                        .read(contactPickerControllerProvider.notifier)
                        .createNewContact,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: AppColors.appBarColor,
                            child: Icon(
                              Icons.person_add,
                              color: AppColors.iconColor,
                            ),
                          ),
                          SizedBox(
                            width: 18.0,
                          ),
                          Text(
                            'New Contact',
                          ),
                        ],
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () => ref
                      .read(contactPickerControllerProvider.notifier)
                      .shareInviteLink(
                        context.findRenderObject() as RenderBox?,
                      ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          backgroundColor: AppColors.appBarColor,
                          child: Icon(
                            Icons.share,
                            color: AppColors.iconColor,
                          ),
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Text(
                          'Share invite link',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: ref
                      .read(contactPickerControllerProvider.notifier)
                      .showHelp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: const [
                        CircleAvatar(
                          backgroundColor: AppColors.appBarColor,
                          child: Icon(
                            Icons.question_mark,
                            color: AppColors.iconColor,
                          ),
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Text(
                          'Contacts help',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWhatsAppContactsList(
    BuildContext context,
    List<Contact> contactsOnWhatsApp,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        child: Text(
          'Contacts on WhatsApp',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      WhatsAppContactsList(
        contactsOnWhatsApp: contactsOnWhatsApp,
        ref: ref,
      )
    ];
  }

  List<Widget> _buildLocalContactsList(
    BuildContext context,
    List<Contact> contactsNotOnWhatsApp,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        child: Text(
          'Invite to WhatsApp',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      LocalContactsList(
        contactsNotOnWhatsApp: contactsNotOnWhatsApp,
        ref: ref,
      ),
    ];
  }
}

class LocalContactsList extends StatelessWidget {
  const LocalContactsList({
    Key? key,
    required this.contactsNotOnWhatsApp,
    required this.ref,
  }) : super(key: key);

  final List<Contact> contactsNotOnWhatsApp;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var contact in contactsNotOnWhatsApp)
          InkWell(
            onTap: () => ref
                .read(contactPickerControllerProvider.notifier)
                .sendSms(contact.phoneNumber),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(contact.avatarUrl),
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  Text(
                    contact.name,
                  ),
                  const Expanded(
                    child: SizedBox(
                      width: double.infinity,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(contactPickerControllerProvider.notifier)
                        .sendSms(contact.phoneNumber),
                    child: Text(
                      'INVITE',
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: AppColors.tabColor),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class WhatsAppContactsList extends StatelessWidget {
  const WhatsAppContactsList({
    Key? key,
    required this.contactsOnWhatsApp,
    required this.ref,
  }) : super(key: key);

  final List<Contact> contactsOnWhatsApp;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var contact in contactsOnWhatsApp)
          InkWell(
            onTap: () => ref
                .read(contactPickerControllerProvider.notifier)
                .pickContact(context, contact),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(contact.avatarUrl),
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        'Hey there! I\'m using WhatsApp.',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
