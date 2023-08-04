import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;
  String contactId;
  String displayName;
  String phoneNumber;
  String? avatarUrl;
  String? userId;

  Contact({
    required this.contactId,
    required this.displayName,
    required this.phoneNumber,
    this.avatarUrl,
    this.userId,
  });

  @override
  String toString() {
    return displayName;
  }
}
