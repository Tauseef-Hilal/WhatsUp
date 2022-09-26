class Phone {
  final String code;
  final String number;
  late final String _formattedNumber;

  Phone({
    required this.code,
    required this.number,
    formattedNumber = '',
  }) : _formattedNumber = formattedNumber;

  String get formattedNumber =>
      _formattedNumber.isNotEmpty ? _formattedNumber : '$code $number';

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
      'rawNumber': toString(),
    };
  }

  @override
  String toString() => '$code$number';
}
