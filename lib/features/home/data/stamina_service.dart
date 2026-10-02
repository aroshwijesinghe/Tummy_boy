import 'dart:math';
import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

/// Ultra-optimized Stamina and Streak calculation engine.
class StaminaService {
  static Future<double> calculateStamina(List<Exercise> allExercises) async {
    final now = DateTime.now();
    int activeDays = 0;

    // Check each of the last 7 days
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final hasExercise = await StorageService.hasAnyExerciseOnDate(date, allExercises);
      if (hasExercise) {
        activeDays++;
      }
    }

    final streak = await getStreak(allExercises);

    final baseStamina = (activeDays / 7) * 100;
    final streakBonus = min(14.0, streak * 2.0);

    return (baseStamina + streakBonus).clamp(0.0, 100.0);
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
