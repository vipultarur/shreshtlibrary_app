import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsEnabledNotifier extends Notifier<bool> {
  static const _prefKey = 'notifications_enabled';

  @override
  bool build() {
    _loadState();
    return true; // Default value is true (notifications enabled)
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_prefKey);
    if (val != null) {
      state = val;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}

final notificationsEnabledProvider = NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);
