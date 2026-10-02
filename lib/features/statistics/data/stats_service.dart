import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

/// Ultra-optimized statistics and aggregation service.
class StatsService {
  /// Batch retrieves and sums weekly totals across all exercises.
  static Future<Map<DateTime, double>> getWeeklyTotal(List<Exercise> exercises, DateTime weekStart) async {
    final totals = <DateTime, double>{};
    final p = await StorageService.prefs;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      double dayTotal = 0;
      for (final ex in exercises) {
        dayTotal += p.getDouble(ex.dailyKey(date)) ?? 0;
      }
      totals[date] = dayTotal;
    }
    return totals;
  }

  /// Batch retrieves and sums monthly totals across all exercises in a single pass.
  static Future<Map<DateTime, double>> getMonthlyTotal(List<Exercise> exercises, int year, int month) async {
    final totals = <DateTime, double>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final p = await StorageService.prefs;

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      double dayTotal = 0;
      for (final ex in exercises) {
        dayTotal += p.getDouble(ex.dailyKey(date)) ?? 0;
      }
      totals[date] = dayTotal;
    }
    return totals;
  }

  static Future<int> getActiveDaysInWeek(List<Exercise> exercises, DateTime weekStart) async {
    final weeklyData = await getWeeklyTotal(exercises, weekStart);
    return weeklyData.values.where((val) => val > 0).length;
  }

  static Future<int> getActiveDaysInMonth(List<Exercise> exercises, int year, int month) async {
    final monthlyData = await getMonthlyTotal(exercises, year, month);
    return monthlyData.values.where((val) => val > 0).length;
  }

  static Future<double> getBestDayInWeek(List<Exercise> exercises, DateTime weekStart) async {
    final weeklyData = await getWeeklyTotal(exercises, weekStart);
    if (weeklyData.isEmpty) return 0;
    return weeklyData.values.reduce((curr, next) => curr > next ? curr : next);
  }
}
