class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String phoneNumber;
  final List groupIds;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.phoneNumber,
    required this.groupIds,
  });

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      avatarUrl: userData['avatarUrl'] as String,
      phoneNumber: userData['phoneNumber'] as String,
      groupIds: userData['groupIds'] as List,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'groupIds': groupIds,
    };
  }
}
