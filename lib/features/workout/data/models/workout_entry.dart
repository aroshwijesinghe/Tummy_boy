class WorkoutEntry {
  final String exerciseName;
  final int reps;
  final DateTime loggedAt;

  const WorkoutEntry({
    required this.exerciseName,
    required this.reps,
    required this.loggedAt,
  });
}
