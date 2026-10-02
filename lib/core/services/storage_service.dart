import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/exercises/data/models/exercise.dart';

/// Centralized, high-performance SharedPreferences wrapper for all data storage.
class StorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initialize early at application startup to remove cold-start I/O delay.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Synchronous & Asynchronous Exercise daily logs ──

  static double getExerciseValueSync(Exercise exercise, DateTime date) {
    if (_prefs == null) return 0;
    return _prefs!.getDouble(exercise.dailyKey(date)) ?? 0;
  }

  static Future<double> getExerciseValue(Exercise exercise, DateTime date) async {
    final p = await prefs;
    return p.getDouble(exercise.dailyKey(date)) ?? 0;
  }

  static Future<void> setExerciseValue(Exercise exercise, DateTime date, double value) async {
    final p = await prefs;
    await p.setDouble(exercise.dailyKey(date), value);
  }

  static Future<void> incrementExercise(Exercise exercise, DateTime date, [double amount = 1]) async {
    final p = await prefs;
    final key = exercise.dailyKey(date);
    final current = p.getDouble(key) ?? 0;
    await p.setDouble(key, current + amount);
  }

  static Future<void> resetExercise(Exercise exercise, DateTime date) async {
    final p = await prefs;
    await p.remove(exercise.dailyKey(date));
  }

  /// Get exercise data for a 7-day span starting from [weekStart].
  static Future<Map<DateTime, double>> getWeeklyExerciseData(
      Exercise exercise, DateTime weekStart) async {
    final p = await prefs;
    final data = <DateTime, double>{};
    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      data[date] = p.getDouble(exercise.dailyKey(date)) ?? 0;
    }
    return data;
  }

  /// Get exercise data for a full month in a single batch read.
  static Future<Map<DateTime, double>> getMonthlyExerciseData(
      Exercise exercise, int year, int month) async {
    final p = await prefs;
    final data = <DateTime, double>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      data[date] = p.getDouble(exercise.dailyKey(date)) ?? 0;
    }
    return data;
  }

  /// Check if ANY exercise was logged on a given date.
  static Future<bool> hasAnyExerciseOnDate(DateTime date, List<Exercise> exercises) async {
    final p = await prefs;
    for (final ex in exercises) {
      final val = p.getDouble(ex.dailyKey(date)) ?? 0;
      if (val > 0) return true;
    }
    return false;
  }

  // ── Custom exercises ──

  static const String _customExercisesKey = 'custom_exercises_json';

  static Future<List<Exercise>> getCustomExercises() async {
    final p = await prefs;
    final jsonStr = p.getString(_customExercisesKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCustomExercises(List<Exercise> exercises) async {
    final p = await prefs;
    final jsonStr = jsonEncode(exercises.map((e) => e.toJson()).toList());
    await p.setString(_customExercisesKey, jsonStr);
  }

  static Future<void> addCustomExercise(Exercise exercise) async {
    final list = await getCustomExercises();
    list.add(exercise);
    await saveCustomExercises(list);
  }

  static Future<void> removeCustomExercise(String exerciseId) async {
    final list = await getCustomExercises();
    list.removeWhere((e) => e.id == exerciseId);
    await saveCustomExercises(list);
    // Remove from active exercises as well, but NEVER delete historical daily logs
    final active = await getActiveExerciseIds();
    if (active.contains(exerciseId)) {
      active.remove(exerciseId);
      await setActiveExerciseIds(active);
    }
  }

  // ── PIN ──

  static const String _pinHashKey = 'pin_hash';
  static const String _pinSetKey = 'pin_is_set';

  static Future<bool> isPinSet() async {
    final p = await prefs;
    return p.getBool(_pinSetKey) ?? false;
  }

  static Future<void> savePinHash(String hash) async {
    final p = await prefs;
    await p.setString(_pinHashKey, hash);
    await p.setBool(_pinSetKey, true);
  }

  static Future<String?> getPinHash() async {
    final p = await prefs;
    return p.getString(_pinHashKey);
  }

  static Future<void> clearPin() async {
    final p = await prefs;
    await p.remove(_pinHashKey);
    await p.setBool(_pinSetKey, false);
  }

  // ── General preferences ──

  static Future<bool> getDarkModeEnabled() async {
    final p = await prefs;
    return p.getBool('dark_mode_enabled') ?? true;
  }

  static Future<void> setDarkModeEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool('dark_mode_enabled', enabled);
  }

  // ── User Assigned / Active Exercises on Home Screen ──
  static const String _activeExerciseIdsKey = 'user_assigned_active_exercise_ids';

  /// Returns the list of exercise IDs assigned by the user to the Home screen.
  /// On fresh install, returns an empty list (user must explicitly assign exercises).
  static Future<List<String>> getActiveExerciseIds() async {
    final p = await prefs;
    final list = p.getStringList(_activeExerciseIdsKey);
    return list ?? [];
  }

  static Future<void> setActiveExerciseIds(List<String> ids) async {
    final p = await prefs;
    await p.setStringList(_activeExerciseIdsKey, ids);
  }

  static Future<bool> isExerciseActive(String exerciseId) async {
    final activeIds = await getActiveExerciseIds();
    return activeIds.contains(exerciseId);
  }

  static Future<void> toggleExerciseActive(String exerciseId, bool active) async {
    final activeIds = await getActiveExerciseIds();
    if (active) {
      if (!activeIds.contains(exerciseId)) {
        activeIds.add(exerciseId);
      }
    } else {
      activeIds.remove(exerciseId);
    }
    await setActiveExerciseIds(activeIds);
  }

  // ── Goals (User Defined Only, No Forced Defaults on Fresh Install) ──

  /// Check whether the user has explicitly defined a goal for this exercise.
  static Future<bool> hasGoal(Exercise exercise) async {
    final p = await prefs;
    return p.containsKey('exercise_goal_${exercise.id}');
  }

  /// Get the user-defined goal. Returns null if user has not yet set a goal for this exercise.
  static Future<double?> getGoal(Exercise exercise) async {
    final p = await prefs;
    return p.getDouble('exercise_goal_${exercise.id}');
  }

  /// Get the user-defined goal with a fallback if desired (or 0.0 if unset).
  static Future<double> getGoalOrDefault(Exercise exercise, [double fallback = 0.0]) async {
    final p = await prefs;
    return p.getDouble('exercise_goal_${exercise.id}') ?? fallback;
  }

  static Future<void> setGoal(Exercise exercise, double goal) async {
    final p = await prefs;
    await p.setDouble('exercise_goal_${exercise.id}', goal);
  }

  static Future<void> removeGoal(Exercise exercise) async {
    final p = await prefs;
    await p.remove('exercise_goal_${exercise.id}');
  }

  // ── Helpers ──

  static DateTime getWeekStart(DateTime date) {
    final diff = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Clear all data (for profile reset).
  static Future<void> clearAllData() async {
    final p = await prefs;
    await p.clear();
  }
}
