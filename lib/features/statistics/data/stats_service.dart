import '../../../core/services/storage_service.dart';
import '../../exercises/data/models/exercise.dart';

class StatsService {
  static Future<Map<DateTime, double>> getWeeklyTotal(List<Exercise> exercises, DateTime weekStart) async {
    Map<DateTime, double> totals = {};
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      double total = 0;
      for (var ex in exercises) {
        total += await StorageService.getExerciseValue(ex, normalizedDate);
      }
      totals[normalizedDate] = total;
    }
    return totals;
  }

  static Future<Map<DateTime, double>> getMonthlyTotal(List<Exercise> exercises, int year, int month) async {
    Map<DateTime, double> totals = {};
    int daysInMonth = DateTime(year, month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      double total = 0;
      for (var ex in exercises) {
        total += await StorageService.getExerciseValue(ex, date);
      }
      totals[date] = total;
    }
    return totals;
  }

  static Future<int> getActiveDaysInWeek(List<Exercise> exercises, DateTime weekStart) async {
    var weeklyData = await getWeeklyTotal(exercises, weekStart);
    return weeklyData.values.where((val) => val > 0).length;
  }

  static Future<int> getActiveDaysInMonth(List<Exercise> exercises, int year, int month) async {
    var monthlyData = await getMonthlyTotal(exercises, year, month);
    return monthlyData.values.where((val) => val > 0).length;
  }

  static Future<double> getBestDayInWeek(List<Exercise> exercises, DateTime weekStart) async {
    var weeklyData = await getWeeklyTotal(exercises, weekStart);
    if (weeklyData.isEmpty) return 0;
    return weeklyData.values.reduce((curr, next) => curr > next ? curr : next);
  }
}
