import 'package:flutter_contacts/flutter_contacts.dart' show FlutterContacts;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/home/data/repositories/firebase_repo.dart';
import 'package:whatsapp_clone/features/home/models/contact.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

final contactsRepositoryProvider = Provider((ref) => ContactsRepository(ref));

class ContactsRepository {
  final ProviderRef ref;

  ContactsRepository(this.ref);

  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<Map<String, List<Contact>>> getContacts() async {
    Map<String, List<Contact>> res = {'onWhatsApp': [], 'notOnWhatsApp': []};

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final firestoreRepo = ref.read(firebaseFirestoreRepositoryProvider);

    for (var contact in contacts) {
      for (var phone in contact.phones) {
        User? user = await firestoreRepo.getUserByPhone(phone.number);
        if (user != null) {
          res['onWhatsApp']!.add(
            Contact(
              name: user.name,
              phoneNumber: user.phoneNumber,
              avatarUrl: user.avatarUrl,
            ),
          );
        } else {
          res['notOnWhatsApp']!.add(
            Contact(
              name: contact.displayName,
              phoneNumber: phone.number,
            ),
          );
        }
      }
    }

    return res;
  }
}
