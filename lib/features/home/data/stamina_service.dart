import 'dart:math';
import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

/// Ultra-optimized Stamina and Streak calculation engine.
class StaminaService {
  static const String _keyLastStamina = 'user_last_stamina_val';
  static const String _keyLastCheckedDate = 'user_stamina_last_checked_date';

  /// Calculates current stamina based on exact user specification:
  /// - If one day you do not exercise, stamina decreases by 10%.
  /// - After decreasing, if one day you do exercise, stamina increases by 100/7% (~14.2857%).
  /// - Capped at 100% max and 0% min.
  static Future<double> calculateStamina(List<Exercise> allExercises) async {
    final p = await StorageService.prefs;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDateStr = p.getString(_keyLastCheckedDate);
    double stamina = p.getDouble(_keyLastStamina) ?? 100.0;

    const double dailyGain = 100.0 / 7.0; // 14.2857%
    const double dailyLoss = 10.0;        // 10.0%

    if (lastDateStr == null) {
      // First time initialization: check past 7 days history
      int active = 0;
      for (int i = 0; i < 7; i++) {
        final d = today.subtract(Duration(days: i));
        if (await StorageService.hasAnyExerciseOnDate(d, allExercises)) {
          active++;
        }
      }
      stamina = ((active * dailyGain) - ((7 - active) * dailyLoss)).clamp(0.0, 100.0);
      await p.setString(_keyLastCheckedDate, today.toIso8601String());
      await p.setDouble(_keyLastStamina, stamina);
      return stamina;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final daysPassed = today.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;

    if (daysPassed > 0) {
      // Process each passed day between last recorded date and yesterday
      for (int d = 1; d <= daysPassed; d++) {
        final checkDate = DateTime(lastDate.year, lastDate.month, lastDate.day + d);
        final hadWorkout = await StorageService.hasAnyExerciseOnDate(checkDate, allExercises);
        if (hadWorkout) {
          stamina = (stamina + dailyGain).clamp(0.0, 100.0);
        } else {
          stamina = (stamina - dailyLoss).clamp(0.0, 100.0);
        }
      }
      await p.setString(_keyLastCheckedDate, today.toIso8601String());
      await p.setDouble(_keyLastStamina, stamina);
    } else {
      // Same day check: if workout was performed today, ensure today's gain is represented
      final hadWorkoutToday = await StorageService.hasAnyExerciseOnDate(today, allExercises);
      if (hadWorkoutToday) {
        // Ensure stamina is at least today's gain
        stamina = max(stamina, dailyGain);
      }
    }

    return stamina.clamp(0.0, 100.0);
  }

  static Future<int> getStreak(List<Exercise> allExercises) async {
    final now = DateTime.now();
    int streak = 0;

    // Check today first
    final today = DateTime(now.year, now.month, now.day);
    final todayHas = await StorageService.hasAnyExerciseOnDate(today, allExercises);
    final offset = todayHas ? 0 : 1;

    // Check backwards up to 365 days max for safety and speed
    for (int i = 0; i < 365; i++) {
      final date = DateTime(now.year, now.month, now.day - (i + offset));
      final hasExercise = await StorageService.hasAnyExerciseOnDate(date, allExercises);
      if (hasExercise) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
