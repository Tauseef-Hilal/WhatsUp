import 'package:country_picker/country_picker.dart';

List<Country> get countriesList => CountryService().getAll();
