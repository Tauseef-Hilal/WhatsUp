import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_number/phone_number.dart';
import 'package:whatsapp_clone/features/auth/views/countries.dart';
import 'package:whatsapp_clone/shared/utils/abc.dart';
import 'package:whatsapp_clone/shared/widgets/dialogs.dart';
import 'package:whatsapp_clone/theme/theme.dart';

import '../../../shared/models/user.dart';
import '../views/verification.dart';

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

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, Country>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<Country> {
  LoginController(this.ref) : super(ref.read(defaultCountryProvider));

  final AutoDisposeStateNotifierProviderRef ref;
  late PhoneNumberEditingController phoneNumberController;
  late final TextEditingController phoneCodeController;

  void init(phoneNumberListener) {
    phoneCodeController = TextEditingController(
      text: state.phoneCode,
    );
    phoneNumberController = PhoneNumberEditingController(
      PhoneNumberUtil(),
      regionCode: state.countryCode,
      behavior: PhoneInputBehavior.strict,
    );

    phoneNumberController.addListener(phoneNumberListener);
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    phoneCodeController.dispose();
    super.dispose();
  }

  Future<void> updateSelectedCountry(
    Country country, [
    bool editPhoneCode = false,
  ]) async {
    if (state == country) return;

    await _formatPhoneNumber(country.countryCode);
    state = country;

    if (editPhoneCode) _updatePhoneCode(country.phoneCode);
  }

  void _updatePhoneCode(String phoneCode) {
    phoneCodeController.text = phoneCode;
  }

  Future<void> _formatPhoneNumber(String countryCode) async {
    final formattedPhoneNumber = await PhoneNumberUtil().format(
        phoneNumberController.text
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll(' ', ''),
        countryCode);

    phoneNumberController.dispose();
    phoneNumberController = PhoneNumberEditingController(
      PhoneNumberUtil(),
      text: formattedPhoneNumber,
      regionCode: countryCode,
      behavior: PhoneInputBehavior.strict,
    );
  }

  void onPhoneCodeChanged(String value) async {
    Country country;
    if (value.isEmpty) {
      country = Country(
        phoneCode: '',
        countryCode: '',
        e164Sc: -1,
        geographic: false,
        level: -1,
        name: 'No such country',
        example: '',
        displayName: 'No such country',
        fullExampleWithPlusSign: '',
        displayNameNoCountryCode: 'No such country',
        e164Key: '',
      );
    } else {
      List results = countriesList
          .where(
            (country) => country.phoneCode == value,
          )
          .toList();

      if (results.isEmpty) {
        country = Country(
          phoneCode: value,
          countryCode: '',
          e164Sc: -1,
          geographic: false,
          level: -1,
          name: 'No such country',
          example: '',
          displayName: 'No such country',
          fullExampleWithPlusSign: '',
          displayNameNoCountryCode: 'No such country',
          e164Key: '',
        );
      } else {
        country = results[0];
      }
    }

    updateSelectedCountry(country);
  }

  void onNextBtnPressed(context) async {
    final colorTheme = Theme.of(context).custom.colorTheme;

    String phoneNumberWithCode =
        '+${state.phoneCode} ${phoneNumberController.text}';

    bool isValidPhoneNumber = false;
    try {
      isValidPhoneNumber =
          await PhoneNumberUtil().validate(phoneNumberWithCode);
    } catch (_) {
      // ...
    }

    String errorMsg = '';
    if (state.name == 'No such country') {
      errorMsg = 'Invalid country code.';

      if (isValidPhoneNumber) {
        isValidPhoneNumber = !isValidPhoneNumber;
      }
    }

    if (!isValidPhoneNumber) {
      if (errorMsg.isEmpty) {
        errorMsg = ref
                .read(loginControllerProvider.notifier)
                .phoneNumberController
                .text
                .isEmpty
            ? 'Please enter your phone number.'
            : 'The phone number your entered is invalid '
                'for the country: ${state.name}';
      }

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.all(0),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? colorTheme.appBarColor
                : colorTheme.backgroundColor,
            content: Text(
              errorMsg,
              style: TextStyle(
                color: colorTheme.greyColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: colorTheme.greenColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? colorTheme.appBarColor
              : colorTheme.backgroundColor,
          actionButtonTextColor: colorTheme.greenColor,
          actionCallbacks: {
            'EDIT': () => Navigator.of(context).pop(),
            'OK': () async {
              final formattedPhoneNumber =
                  '+${state.phoneCode.trim()} ${phoneNumberController.text.trim()}';
              final phone = Phone(
                code: '+${state.phoneCode.trim()}',
                number: ref
                    .read(loginControllerProvider.notifier)
                    .phoneNumberController
                    .text
                    .replaceAll(' ', '')
                    .replaceAll('-', '')
                    .replaceAll('(', '')
                    .replaceAll(')', ''),
                formattedNumber: formattedPhoneNumber,
              );

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => VerificationPage(phone: phone),
                ),
                (route) => false,
              );
            },
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You entered the phone number:',
                style: TextStyle(color: colorTheme.greyColor, fontSize: 16),
              ),
              const SizedBox(height: 16.0),
              Text(
                phoneNumberWithCode,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorTheme.greyColor,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Is this OK, or would you like to edit '
                'the number?',
                style: TextStyle(
                  color: colorTheme.greyColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCountryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => const CountryPage()),
      ),
    );
  }
}

final countryPickerControllerProvider =
    StateNotifierProvider.autoDispose<CountryPickerController, List<Country>>(
  (ref) => CountryPickerController(ref),
);

class CountryPickerController extends StateNotifier<List<Country>> {
  CountryPickerController(this.ref) : super(countriesList);
  final AutoDisposeStateNotifierProviderRef ref;
  late final TextEditingController searchController;
  late final List<Country> _countries;

  void init() {
    searchController = TextEditingController();
    _countries = countriesList;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void initialUpdate() {
    final selectedCountry = ref.read(loginControllerProvider);

    state = [
      selectedCountry,
      ...countriesList.where((country) => country != selectedCountry)
    ];
  }

  void setCountry(BuildContext context, Country country) {
    ref
        .read(loginControllerProvider.notifier)
        .updateSelectedCountry(country, true)
        .whenComplete(() => Navigator.of(context).pop());
  }

  void onCrossPressed() {
    searchController.clear();
    state = _countries;
  }

  void updateSearchResults(String query) {
    query = query.toLowerCase().trim();
    state = _countries
        .where(
          (country) => country.name.toLowerCase().startsWith(query),
        )
        .toList();
  }
}
