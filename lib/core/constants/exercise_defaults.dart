import 'package:flutter/material.dart';
import '../../features/exercises/data/models/exercise.dart';
import 'app_colors.dart';

/// The 6 built-in exercises shipped with the app.
class ExerciseDefaults {
  ExerciseDefaults._();

  static const List<Exercise> builtIn = [
    Exercise(
      id: 'pushups',
      name: 'Pushups',
      unit: 'reps',
      icon: Icons.fitness_center,
      accentColor: AppColors.pushupColor,
      isBuiltIn: true,
    ),
    Exercise(
      id: 'squats',
      name: 'Squats',
      unit: 'reps',
      icon: Icons.accessibility_new,
      accentColor: AppColors.squatColor,
      isBuiltIn: true,
    ),
    Exercise(
      id: 'running',
      name: 'Running',
      unit: 'km',
      icon: Icons.directions_run,
      accentColor: AppColors.runColor,
      isBuiltIn: true,
    ),
    Exercise(
      id: 'jumping_jacks',
      name: 'Jumping Jacks',
      unit: 'reps',
      icon: Icons.sports_martial_arts,
      accentColor: AppColors.jumpColor,
      isBuiltIn: true,
    ),
    Exercise(
      id: 'planks',
      name: 'Planks',
      unit: 'seconds',
      icon: Icons.self_improvement,
      accentColor: AppColors.plankColor,
      isBuiltIn: true,
    ),
    Exercise(
      id: 'situps',
      name: 'Sit-ups',
      unit: 'reps',
      icon: Icons.airline_seat_flat,
      accentColor: AppColors.situpColor,
      isBuiltIn: true,
    ),
  ];

  /// Available icons for custom exercises.
  static const List<IconData> availableIcons = [
    Icons.fitness_center,
    Icons.directions_run,
    Icons.accessibility_new,
    Icons.sports_martial_arts,
    Icons.self_improvement,
    Icons.airline_seat_flat,
    Icons.sports_gymnastics,
    Icons.sports_handball,
    Icons.pool,
    Icons.directions_bike,
    Icons.hiking,
    Icons.sports_tennis,
  ];

  /// Available accent colors for custom exercises.
  static const List<Color> availableColors = [
    AppColors.pushupColor,
    AppColors.squatColor,
    AppColors.runColor,
    AppColors.jumpColor,
    AppColors.plankColor,
    AppColors.situpColor,
  ];
}
