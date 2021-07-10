import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const LAST_PAGE_URL = 'LAST_PAGE_URL';

  final Future<SharedPreferences> prefs;

  Prefs() :
    prefs = SharedPreferences.getInstance();

  Future<String?> getLastPageUrl() {
    return prefs.then((prefs) => prefs.getString(LAST_PAGE_URL));
  }

  Future<bool> setLastPageUrl(String value) {
    return prefs.then((prefs) => prefs.setString(LAST_PAGE_URL, value));
  }
}
