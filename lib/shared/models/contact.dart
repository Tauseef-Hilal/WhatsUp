class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String avatarUrl;

  Contact({
    this.id = '',
    required this.name,
    required this.phoneNumber,
    this.avatarUrl = 'http://www.gravatar.com/avatar/?d=mp',
  });

  factory Contact.fromMap(Map<String, dynamic> contactData) {
    return Contact(
      name: contactData['name'] as String,
      avatarUrl: contactData['avatarUrl'] as String,
      phoneNumber: contactData['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
    };
  }
}
