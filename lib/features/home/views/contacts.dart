import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/home/controllers/contacts_controller.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/widgets/search.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ContactsPage extends ConsumerStatefulWidget {
  final User user;
  const ContactsPage({super.key, required this.user});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  @override
  void initState() {
    ref.read(contactPickerControllerProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).custom.colorTheme;
    final searchResults = ref.watch(contactPickerControllerProvider);
    final contactsOnWhatsApp =
        searchResults.where((contact) => contact.userId != null).toList();
    final contactsNotOnWhatsApp =
        searchResults.where((contact) => contact.userId == null).toList();

    String searchQuery = ref
        .read(contactPickerControllerProvider.notifier)
        .searchController
        .text;

    bool buildWhatsAppContactsList = contactsOnWhatsApp.isNotEmpty;
    bool buildLocalContactsList = contactsNotOnWhatsApp.isNotEmpty;

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
          ref.read(contactsProvider).isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorTheme.greenColor,
                  ),
                )
              : const Text(''),
          PopupMenuButton(
            onSelected: (value) {},
            color: colorTheme.appBarColor,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
            itemBuilder: (context) {
              TextStyle popupMenuTextStyle = Theme.of(context)
                  .custom
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.white);
              return <PopupMenuEntry>[
                PopupMenuItem(
                    onTap: () => ref
                        .read(contactPickerControllerProvider.notifier)
                        .shareInviteLink(
                          context.findRenderObject() as RenderBox?,
                        ),
                    child: Text(
                      'Invite a friend',
                      style: Theme.of(context)
                          .custom
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.white),
                    )),
                PopupMenuItem(
                    onTap: ref
                        .read(contactPickerControllerProvider.notifier)
                        .openContacts,
                    child: Text(
                      'Contacts',
                      style: Theme.of(context)
                          .custom
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.white),
                    )),
                PopupMenuItem(
                    onTap: () {
                      ref
                          .read(contactPickerControllerProvider.notifier)
                          .refreshContactsList();
                    },
                    child: Text(
                      'Refresh',
                      style: Theme.of(context)
                          .custom
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.white),
                    )),
                PopupMenuItem(
                    onTap: ref
                        .read(contactPickerControllerProvider.notifier)
                        .showHelp,
                    child: Text(
                      'Help',
                      style: popupMenuTextStyle,
                    )),
              ];
            },
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
          physics: const BouncingScrollPhysics(),
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
                  style: Theme.of(context).custom.textTheme.caption,
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
                        children: [
                          CircleAvatar(
                            backgroundColor: colorTheme.greenColor,
                            child: const Icon(
                              Icons.people,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 18.0,
                          ),
                          Text(
                            'New group',
                            style: Theme.of(context).custom.textTheme.bold,
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
                        children: [
                          CircleAvatar(
                            backgroundColor: colorTheme.greenColor,
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 18.0,
                          ),
                          Text('New contact',
                              style: Theme.of(context).custom.textTheme.bold),
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
                  style: Theme.of(context).custom.textTheme.caption,
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
                        children: [
                          CircleAvatar(
                            backgroundColor: colorTheme.appBarColor,
                            child: Icon(
                              Icons.person_add,
                              color: colorTheme.iconColor,
                            ),
                          ),
                          const SizedBox(
                            width: 18.0,
                          ),
                          Text('New Contact',
                              style: Theme.of(context).custom.textTheme.bold),
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
                      children: [
                        CircleAvatar(
                          backgroundColor: colorTheme.appBarColor,
                          child: Icon(
                            Icons.share,
                            color: colorTheme.iconColor,
                          ),
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Text('Share invite link',
                            style: Theme.of(context).custom.textTheme.bold),
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
                      children: [
                        CircleAvatar(
                          backgroundColor: colorTheme.appBarColor,
                          child: Icon(
                            Icons.question_mark,
                            color: colorTheme.iconColor,
                          ),
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Text('Contacts help',
                            style: Theme.of(context).custom.textTheme.bold),
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
          style: Theme.of(context).custom.textTheme.caption,
        ),
      ),
      WhatsAppContactsList(
        user: widget.user,
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
          style: Theme.of(context).custom.textTheme.caption,
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
    super.key,
    required this.contactsNotOnWhatsApp,
    required this.ref,
  });

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
                  const CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  Text(
                    contact.displayName,
                    style: Theme.of(context).custom.textTheme.bold,
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
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              Theme.of(context).custom.colorTheme.greenColor),
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
  final User user;

  const WhatsAppContactsList({
    super.key,
    required this.user,
    required this.contactsOnWhatsApp,
    required this.ref,
  });

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
                .pickContact(context, user, contact),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(
                      contact.avatarUrl!,
                    ),
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.displayName,
                          style: Theme.of(context).custom.textTheme.bold),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        'Hey there! I\'m using WhatsApp.',
                        style: Theme.of(context).custom.textTheme.caption,
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
