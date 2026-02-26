class ProgressSummary {
  final int totalReps;
  final double totalDistanceMeters;
  final DateTime periodStart;
  final DateTime periodEnd;

  const ProgressSummary({
    required this.totalReps,
    required this.totalDistanceMeters,
    required this.periodStart,
    required this.periodEnd,
  });
}
