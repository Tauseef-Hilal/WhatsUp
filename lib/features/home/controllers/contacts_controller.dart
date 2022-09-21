import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/features/chat/views/chat.dart';

final contactsProvider = FutureProvider((ref) async {
  return ref.watch(contactsRepositoryProvider).getContacts();
});

final contactPickerControllerProvider = StateNotifierProvider.autoDispose<
    ContactPickerController, Map<String, List<Contact>>>(
  (ref) => ContactPickerController(ref),
);

const shareMsg =
    'Let\'s chat on WhatsApp! It\'s a fast, simple, and secure app we can use to message and call each other for free. Get it at https://github.com/Tauseef-Hilal/whatsapp-clone/releases/';

class ContactPickerController
    extends StateNotifier<Map<String, List<Contact>>> {
  late Map<String, List<Contact>> _contacts;

  final TextEditingController searchController = TextEditingController();
  final AutoDisposeStateNotifierProviderRef ref;

  ContactPickerController(this.ref)
      : super({'onWhatsApp': [], 'notOnWhatsApp': []});

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
    ref.refresh(contactsProvider);
  }

  void pickContact(BuildContext context, Contact contact) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(contact: contact),
        ),
        (route) => false);
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
    final Map<String, List<Contact>> temp = {};

    temp['onWhatsApp'] = _contacts['onWhatsApp']!
        .where((contact) => contact.name.toLowerCase().startsWith(query))
        .toList();

    temp['notOnWhatsApp'] = _contacts['notOnWhatsApp']!
        .where((contact) => contact.name.toLowerCase().startsWith(query))
        .toList();

    state = temp;
  }
}
