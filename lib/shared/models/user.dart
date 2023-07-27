import 'package:whatsapp_clone/shared/models/phone.dart';

enum UserActivityStatus {
  online('Online'),
  offline('Offline');

  const UserActivityStatus(this.value);
  final String value;

  factory UserActivityStatus.fromValue(String value) {
    final res = UserActivityStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid status code';
    }

    return res.first;
  }
}

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final Phone phone;
  UserActivityStatus activityStatus;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.activityStatus,
  });

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
      id: userData['id'],
      name: userData['name'],
      avatarUrl: userData['avatarUrl'],
      phone: Phone.fromMap(userData['phone']),
      activityStatus: UserActivityStatus.fromValue(userData['activityStatus']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'phone': phone.toMap(),
      'activityStatus': activityStatus.value,
    };
  }
}
