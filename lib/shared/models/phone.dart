class Phone {
  final String code;
  final String number;

  Phone({
    required this.code,
    required this.number,
  });

  factory Phone.fromMap(Map<String, dynamic> phoneData) {
    return Phone(
      code: phoneData['code'],
      number: phoneData['number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'number': number,
    };
  }

  @override
  String toString() => '$code$number';
}
