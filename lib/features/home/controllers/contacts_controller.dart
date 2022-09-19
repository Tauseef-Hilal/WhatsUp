import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' show FlutterContacts;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/views/chat.dart';

final contactsProvider = FutureProvider((ref) {
  return ref.watch(contactsRepositoryProvider).getContacts();
});

final contactPickerControllerProvider = StateNotifierProvider.autoDispose<
    ContactPickerController, Map<String, List<Contact>>>(
  (ref) => ContactPickerController(ref),
);

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

    FlutterContacts.addListener(update);
  }

  @override
  void dispose() {
    searchController.dispose();
    FlutterContacts.removeListener(update);
    super.dispose();
  }

  void update() async {
    ref.refresh(contactsProvider);
    _contacts = await ref.read(contactsProvider.future);
    updateSearchResults(searchController.text);
  }

  void pickContact(BuildContext context, Contact contact) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(contact: contact),
        ),
        (route) => false);
  }

  void onCrossPressed() {
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
