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
  final String phoneNumber;
  final List groupIds;
  UserActivityStatus activityStatus;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.phoneNumber,
    required this.groupIds,
    required this.activityStatus,
  });

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      avatarUrl: userData['avatarUrl'] as String,
      phoneNumber: userData['phoneNumber'] as String,
      groupIds: userData['groupIds'] as List,
      activityStatus: UserActivityStatus.fromValue(userData['activityStatus']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'groupIds': groupIds,
      'activityStatus': activityStatus.value,
    };
  }
}
