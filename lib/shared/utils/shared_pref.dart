import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static late SharedPreferences _sharedPref;

  static Future<void> init() async {
    _sharedPref = await SharedPreferences.getInstance();
  }

  static Future<void> setDouble(String key, double value) async {
    _sharedPref.setDouble(key, value);
  }

  static double getDouble(String key) {
    return _sharedPref.getDouble(key) ?? 0;
  }
}
