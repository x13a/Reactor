import 'package:shared_preferences/shared_preferences.dart';

class ReactorPrefs {
  static const LAST_PAGE_URL = 'LAST_PAGE_URL';

  final Future<SharedPreferences> prefs;
  final String prefix;

  ReactorPrefs(this.prefix) :
    prefs = SharedPreferences.getInstance();

  Future<String?> getLastPageUrl() {
    return prefs.then((prefs) => prefs.getString('${prefix}_$LAST_PAGE_URL'));
  }

  Future<bool> setLastPageUrl(String value) {
    return prefs.then((prefs) =>
      prefs.setString('${prefix}_$LAST_PAGE_URL', value));
  }
}
