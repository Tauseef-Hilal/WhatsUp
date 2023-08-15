import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/features/chat/views/chat.dart';
import 'package:whatsapp_clone/shared/models/user.dart';
import 'package:whatsapp_clone/shared/repositories/isar_db.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  if (await isConnected()) {
    await IsarDb.refreshContacts();
  }

  return IsarDb.getContacts();
});

final contactPickerControllerProvider =
    StateNotifierProvider.autoDispose<ContactPickerController, List<Contact>>(
  (ref) => ContactPickerController(ref),
);

const shareMsg =
    'Let\'s chat on WhatsApp! It\'s a fast, simple, and secure app we can use to message and call each other for free. Get it at https://github.com/Tauseef-Hilal/whatsapp-clone/releases/';

class ContactPickerController extends StateNotifier<List<Contact>> {
  late List<Contact> _contacts;

  final TextEditingController searchController = TextEditingController();
  final AutoDisposeStateNotifierProviderRef ref;
  bool contactsRefreshing = false;

  ContactPickerController(this.ref) : super([]);

  Future<void> init() async {
    _contacts = await ref.read(contactsProvider.future);
    state = _contacts;

    ref.listen(contactsProvider, (previous, next) {
      next.whenData(
        (value) {
          _contacts = value;
          updateSearchResults(searchController.text);
        },
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openContacts() {
    ref.read(contactsRepositoryProvider).openContacts();
  }

  void refreshContactsList() {
    ref.invalidate(contactsProvider);
  }

  void pickContact(BuildContext context, User sender, Contact contact) async {
    final receiver = await IsarDb.getUserById(contact.userId!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          self: sender,
          other: receiver!,
          otherUserContactName: contact.displayName,
        ),
        settings: const RouteSettings(name: 'chat'),
      ),
    );
  }

  void createNewContact() {
    ref.read(contactsRepositoryProvider).createNewContact();
  }

  void shareInviteLink(RenderBox? box) {
    Share.share(
      shareMsg,
      subject: 'WhatsApp Messenger: Android + iPhone',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void sendSms(String phoneNumber) {
    launchUrl(Uri.parse('sms:$phoneNumber?body=$shareMsg'));
  }

  void showHelp() {
    launchUrl(
      Uri.parse(
        'https://faq.whatsapp.com/cxt?entrypointid=missingcontacts&lg=en&lc=GB&platform=android&anid=c93a2583-9f2f-4e30-8b8c-ed7e6cc01c4d',
      ),
    );
  }

  void onCloseBtnPressed() {
    searchController.clear();
    state = _contacts;
  }

  void updateSearchResults(String query) {
    query = query.toLowerCase().trim();

    state = _contacts.where((contact) {
      return contact.displayName.toLowerCase().startsWith(query);
    }).toList();
  }
}
