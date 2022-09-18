import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/home/data/repositories/contact_repository.dart';
import 'package:whatsapp_clone/features/home/models/contact.dart';

final contactPickerControllerProvider = StateNotifierProvider.autoDispose<
    ContactPickerController, Map<String, List<Contact>>>(
  (ref) => ContactPickerController(ref),
);

class ContactPickerController
    extends StateNotifier<Map<String, List<Contact>>> {
  final AutoDisposeStateNotifierProviderRef ref;
  late final TextEditingController searchController;
  late final Map<String, List<Contact>> _contacts;

  ContactPickerController(this.ref)
      : super({'onWhatsApp': [], 'notOnWhatsApp': []});

  Future<void> init() async {
    searchController = TextEditingController();

    final contactRepository = ref.read(contactsRepositoryProvider);
    _contacts = await contactRepository.getContacts();

    state = _contacts;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void pickContact(BuildContext context, Contact contact) {}

  void onCrossPressed() {
    searchController.clear();
    state = _contacts;
  }

  void updateSearchResults(String query) {
    query = query.toLowerCase().trim();
    final Map<String, List<Contact>> temp = {};
    temp['onWhatsApp'] = _contacts['onWhatsApp']!
        .where(
          (contact) => contact.name.toLowerCase().startsWith(query),
        )
        .toList();

    temp['notOnWhatsApp'] = _contacts['notOnWhatsApp']!
        .where(
          (contact) => contact.name.toLowerCase().startsWith(query),
        )
        .toList();
    
    state = temp;
  }
}
