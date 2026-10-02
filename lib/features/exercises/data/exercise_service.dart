import '../../../core/services/storage_service.dart';
import 'models/exercise.dart';
import '../../../core/constants/exercise_defaults.dart';

class ExerciseService {
  static Future<List<Exercise>> getAllExercises() async {
    const builtIn = ExerciseDefaults.builtIn;
    final custom = await StorageService.getCustomExercises();
    return [...builtIn, ...custom];
  }

  /// Returns only exercises that the user has explicitly assigned/enabled for the Home screen.
  static Future<List<Exercise>> getActiveExercises() async {
    final all = await getAllExercises();
    final activeIds = await StorageService.getActiveExerciseIds();
    return all.where((e) => activeIds.contains(e.id)).toList();
  }

  static Future<bool> isExerciseActive(Exercise exercise) async {
    return await StorageService.isExerciseActive(exercise.id);
  }

  static Future<void> toggleExerciseActive(Exercise exercise, bool active) async {
    await StorageService.toggleExerciseActive(exercise.id, active);
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
