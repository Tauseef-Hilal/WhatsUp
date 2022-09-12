import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

List<Country> get countriesList => CountryService().getAll();

String strFormattedTime(int seconds) {
  String result = DateFormat('H:m:s').format(
    DateTime(2022, 1, 1, 0, 0, seconds),
  );

  List resultParts = result.split(':');
  resultParts.removeWhere((element) => element == '0');

  return resultParts.join(':');
}
