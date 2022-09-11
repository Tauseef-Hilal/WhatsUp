import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_number/phone_number.dart';

final defaultCountryProvider = Provider(
  (ref) => Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    fullExampleWithPlusSign: '+919123456789',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  ),
);

final countryPickerControllerProvider =
    StateNotifierProvider<CountryPickerController, Country>(
        (ref) => CountryPickerController(ref));

class CountryPickerController extends StateNotifier<Country> {
  CountryPickerController(this.ref) : super(ref.read(defaultCountryProvider));
  final StateNotifierProviderRef ref;

  Future<void> update(Country country, [bool editPhoneCode = false]) async {
    await ref
        .read(phoneNumberControllerProvider.notifier)
        .formatNumber(country);
    state = country;

    if (editPhoneCode) {
      ref.read(phoneCodeControllerProvider.notifier).update(country);
    }
  }
}

final phoneCodeControllerProvider =
    StateNotifierProvider<PhoneCodeController, String>(
        (ref) => PhoneCodeController(ref));

class PhoneCodeController extends StateNotifier<String> {
  PhoneCodeController(this.ref) : super('');
  final StateNotifierProviderRef ref;

  void update(Country country) async {
    state = country.phoneCode;
  }
}

final phoneNumberControllerProvider =
    StateNotifierProvider<PhoneNumberController, String>(
        (ref) => PhoneNumberController());

class PhoneNumberController extends StateNotifier<String> {
  PhoneNumberController() : super('');

  Future<void> formatNumber(Country country) async {
    state = await PhoneNumberUtil().format(
        state
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll(' ', ''),
        country.countryCode);
  }

  String update(String phoneNumber) {
    state = phoneNumber;
    return state;
  }
}
