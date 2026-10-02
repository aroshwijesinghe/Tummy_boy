import '../../../core/services/storage_service.dart';
import 'models/exercise.dart';
import '../../../core/constants/exercise_defaults.dart';

class ExerciseService {
  static Future<List<Exercise>> getAllExercises() async {
    const builtIn = ExerciseDefaults.builtIn;
    final custom = await StorageService.getCustomExercises();
    return [...builtIn, ...custom];
  }

  static Future<double> getTodayValue(Exercise exercise) async {
    final today = DateTime.now();
    return await StorageService.getExerciseValue(exercise, today);
  }

  static Future<void> logValue(Exercise exercise, double value) async {
    final today = DateTime.now();
    await StorageService.setExerciseValue(exercise, today, value);
  }

  static Future<void> addToday(Exercise exercise, double amount) async {
    final today = DateTime.now();
    await StorageService.incrementExercise(exercise, today, amount);
  }
}
