import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static const _key = 'notifications_enabled';

  static Future<void> toggleNotifications(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isEnabled);
  }

  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }
}
