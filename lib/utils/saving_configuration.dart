import 'package:shared_preferences/shared_preferences.dart';


class SavingPreferences {
  static late SharedPreferencesAsync _prefs;

  static Future<void> init() async => _prefs = SharedPreferencesAsync();

  static Future<void> saveConfigurationMadhab(String madhab) async {
    await _prefs.setString('madhab', madhab);
  }

  static Future<void> saveConfigurationMethod(String method) async {
    await _prefs.setString('method', method);
  }

  static Future<String?> getConfigurationMadhab() async {
    return _prefs.getString('madhab');
  }

  static Future<String?> getConfigurationMethod() async {
    return _prefs.getString('method');
  }

}