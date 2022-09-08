import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final countryPickerControllerProvider =
    StateNotifierProvider<CountryPickerStateNotifier, CountryPickerController>(
  (ref) => CountryPickerStateNotifier(),
);

class CountryPickerController {
  late Country selectedCountry;
  late final TextEditingController _phoneCodeController;
  final List<Country> _countries = CountryService().getAll();

  CountryPickerController(TextEditingController phoneCodeController) {
    selectedCountry = _countries.firstWhere(
      (country) => country.name == 'India',
    );

    _phoneCodeController = phoneCodeController;
  }

  TextEditingController get phoneCodeController => _phoneCodeController;

  CountryPickerController withSelectedCountry({
    required Country country,
    bool editPhoneCode = false,
  }) {
    return !editPhoneCode
        ? (CountryPickerController(_phoneCodeController)
          ..selectedCountry = country)
        : (CountryPickerController(_phoneCodeController)
          ..selectedCountry = country
          .._phoneCodeController.text = country.phoneCode);
  }
}

class CountryPickerStateNotifier
    extends StateNotifier<CountryPickerController> {
  CountryPickerStateNotifier()
      : super(CountryPickerController(TextEditingController(text: '91')));

  void update({
    required Country country,
    bool editPhoneCode = false,
  }) {
    state = state.withSelectedCountry(
      country: country,
      editPhoneCode: editPhoneCode,
    );
  }
}
