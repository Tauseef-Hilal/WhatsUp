import 'package:isar/isar.dart';
part 'user.g.dart';

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

@collection
class User {
  Id isarId = Isar.autoIncrement;
  final String id;
  final String name;
  final String avatarUrl;
  final Phone phone;

  @Enumerated(EnumType.value, 'value')
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

  @override
  String toString() {
    return name;
  }
}

@embedded
class Phone {
  String? code;
  String? number;
  String? formattedNumber;

  Phone({
    this.code,
    this.number,
    this.formattedNumber,
  });

  String getFormattedNumber() => formattedNumber ?? '$code $number';
  String get rawNumber => '$code$number';

  factory Phone.fromMap(Map<String, dynamic> phoneData) {
    return Phone(
      code: phoneData['code'],
      number: phoneData['number'],
      formattedNumber: phoneData['formattedNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'number': number,
      'formattedNumber': formattedNumber,
      'rawNumber': rawNumber,
    };
  }
}
