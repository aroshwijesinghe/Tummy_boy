import 'package:shared_preferences/shared_preferences.dart';

class PushupService {
  static const String _pushupPrefix = 'pushup_';
  static const String _runPrefix = 'run_';
  static const String _darkModeKey = 'dark_mode_enabled';

  static Future<void> incrementPushupCount(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPushupKey(date);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<void> setPushupCount(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getPushupKey(date), count);
  }

  static Future<int> getPushupCount(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getPushupKey(date)) ?? 0;
  }

  static Future<void> resetPushupCount(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getPushupKey(date));
  }

  static Future<void> setRunDistance(DateTime date, double distanceKm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_getRunKey(date), distanceKm);
  }

  static Future<double> getRunDistance(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_getRunKey(date)) ?? 0;
  }

  static Future<Map<DateTime, int>> getWeeklyData(DateTime weekStart) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <DateTime, int>{};

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      data[date] = prefs.getInt(_getPushupKey(date)) ?? 0;
    }

    return data;
  }

  static Future<Map<DateTime, double>> getWeeklyRunData(DateTime weekStart) async {
    final prefs = await SharedPreferences.getInstance();
    final data = <DateTime, double>{};

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      data[date] = prefs.getDouble(_getRunKey(date)) ?? 0;
    }

    return data;
  }

  static Future<Map<DateTime, int>> getAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <DateTime, int>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_pushupPrefix)) continue;
      final dateStr = key.replaceFirst(_pushupPrefix, '');
      final date = _parseDate(dateStr);
      if (date == null) continue;
      data[date] = prefs.getInt(key) ?? 0;
    }

    return data;
  }

  static Future<bool> getDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  static String _getPushupKey(DateTime date) => '$_pushupPrefix${_dateKey(date)}';

  static String _getRunKey(DateTime date) => '$_runPrefix${_dateKey(date)}';

  static String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static DateTime getWeekStart(DateTime date) {
    final difference = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: difference));
  }

  static DateTime getMonday(DateTime date) {
    final difference = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: difference));
  }
}
