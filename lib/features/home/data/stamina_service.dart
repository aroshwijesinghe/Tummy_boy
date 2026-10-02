import 'dart:math';
import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

class StaminaService {
  static Future<double> calculateStamina(List<Exercise> allExercises) async {
    final now = DateTime.now();
    int activeDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final hasExercise = await StorageService.hasAnyExerciseOnDate(date, allExercises);
      if (hasExercise) {
        activeDays++;
      }
    }

    final streak = await getStreak(allExercises);

    final baseStamina = (activeDays / 7) * 100;
    final streakBonus = min(14.0, streak * 2.0);

    return min(100.0, baseStamina + streakBonus);
  }

  static Future<int> getStreak(List<Exercise> allExercises) async {
    final now = DateTime.now();
    int streak = 0;
    
    // Check today first
    bool todayHas = await StorageService.hasAnyExerciseOnDate(now, allExercises);
    int offset = 0;
    if (!todayHas) {
      // If today has no exercise, we can still have a streak from yesterday
      offset = 1;
    }

    while (true) {
      final date = now.subtract(Duration(days: streak + offset));
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
