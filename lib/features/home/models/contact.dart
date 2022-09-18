class Contact {
  final String name;
  final String phoneNumber;
  final String avatarUrl;

  Contact({
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
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
    };
  }
}
