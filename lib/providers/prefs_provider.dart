import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider {
  // Singleton
  static final _instance = PrefsProvider._();
  factory PrefsProvider() {
    return _instance;
  }
  PrefsProvider._();
  // Actual prefs
  SharedPreferences _prefs;
  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }
  // Fields
  get userId => _prefs.getString('userId');
  set userId(String s) => _prefs.setString('userId',s);



}