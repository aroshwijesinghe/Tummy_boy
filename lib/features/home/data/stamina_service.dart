import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

/// Ultra-optimized Stamina and Streak calculation engine.
class StaminaService {
  static const String _keyLastStamina = 'user_last_stamina_val';
  static const String _keyLastCheckedDate = 'user_stamina_last_checked_date';

  /// Calculates the overall daily goal completion percentage across all exercises (0.0 to 1.0).
  static Future<double> calculateDailyGoalProgress(List<Exercise> allExercises) async {
    if (allExercises.isEmpty) return 0.0;
    final now = DateTime.now();
    double totalProgressSum = 0.0;

    for (final ex in allExercises) {
      final current = await StorageService.getExerciseValue(ex, now);
      final goal = await StorageService.getGoal(ex);
      final double progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
      totalProgressSum += progress;
    }

    return (totalProgressSum / allExercises.length).clamp(0.0, 1.0);
  }

  /// Calculates current stamina based on exact user specification:
  /// - If one day you do not exercise, stamina decreases by 10%.
  /// - When exercising, stamina increases by (100 / 7) * (overall daily progress percentage).
  /// - If all daily goals are 100% completed, full +100/7% is earned.
  static Future<double> calculateStamina(List<Exercise> allExercises) async {
    final p = await StorageService.prefs;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDateStr = p.getString(_keyLastCheckedDate);
    double stamina = p.getDouble(_keyLastStamina) ?? 100.0;

    const double maxDailyGain = 100.0 / 7.0; // 14.2857%
    const double dailyLoss = 10.0;           // 10.0%

    // Calculate today's overall progress (0.0 to 1.0)
    final double todayProgress = await calculateDailyGoalProgress(allExercises);
    final double todayEarnedGain = maxDailyGain * todayProgress;

    if (lastDateStr == null) {
      // First time initialization: check past 7 days history
      int active = 0;
      for (int i = 0; i < 7; i++) {
        final d = today.subtract(Duration(days: i));
        if (await StorageService.hasAnyExerciseOnDate(d, allExercises)) {
          active++;
        }
      }
      stamina = ((active * maxDailyGain) - ((7 - active) * dailyLoss)).clamp(0.0, 100.0);
      await p.setString(_keyLastCheckedDate, today.toIso8601String());
      await p.setDouble(_keyLastStamina, stamina);
      return (stamina + todayEarnedGain).clamp(0.0, 100.0);
    }

    final lastDate = DateTime.parse(lastDateStr);
    final daysPassed = today.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;

    if (daysPassed > 0) {
      // Process past days that have completed
      for (int d = 1; d <= daysPassed; d++) {
        final checkDate = DateTime(lastDate.year, lastDate.month, lastDate.day + d);
        if (checkDate.isBefore(today)) {
          final hadWorkout = await StorageService.hasAnyExerciseOnDate(checkDate, allExercises);
          if (hadWorkout) {
            stamina = (stamina + maxDailyGain).clamp(0.0, 100.0);
          } else {
            stamina = (stamina - dailyLoss).clamp(0.0, 100.0);
          }
        }
      }
      await p.setString(_keyLastCheckedDate, today.toIso8601String());
      await p.setDouble(_keyLastStamina, stamina);
    }

    // Now factor today's earned gain based on overall daily progress percentage
    final double currentStamina = (stamina + todayEarnedGain).clamp(0.0, 100.0);
    return currentStamina;
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
