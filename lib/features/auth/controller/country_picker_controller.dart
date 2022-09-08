import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final countryPickerControllerProvider =
    StateNotifierProvider<CountryPickerStateNotifier, CountryPickerController>(
  (ref) {
    return CountryPickerStateNotifier();
  },
);

class CountryPickerController {
  late Country selectedCountry;
  late final TextEditingController phoneCodeController;
  final List<Country> _countries = CountryService().getAll();

  CountryPickerController() {
    selectedCountry = _countries.firstWhere(
      (country) => country.name == 'India',
    );

    phoneCodeController = TextEditingController(
      text: selectedCountry.phoneCode,
    );
  }

  CountryPickerController withSelectedCountry(Country country) {
    return CountryPickerController()
      ..selectedCountry = country
      ..phoneCodeController.text = country.phoneCode;
  }
}

class CountryPickerStateNotifier
    extends StateNotifier<CountryPickerController> {
  CountryPickerStateNotifier() : super(CountryPickerController());

  void update(Country country) {
    state.phoneCodeController.dispose();
    state = state.withSelectedCountry(country);
  }
}
