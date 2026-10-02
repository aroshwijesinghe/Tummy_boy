import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/exercise_defaults.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../data/stats_service.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../../../../core/services/app_data_sync.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isWeekly = true;
  DateTime _currentWeekStart = _getStartOfWeek(DateTime.now());
  DateTime _currentMonthDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Exercise> _allExercises = [];
  Map<DateTime, double> _weeklyData = {};
  Map<DateTime, double> _monthlyData = {};
  int _activeDaysInWeek = 0;
  double _bestDayInWeek = 0;
  double _totalWeekValue = 0;

  static DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
  }

  @override
  void initState() {
    super.initState();
    AppDataSync.instance.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    AppDataSync.instance.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final customExercises = await StorageService.getCustomExercises();
    _allExercises = [...ExerciseDefaults.builtIn, ...customExercises];

    if (_isWeekly) {
      _weeklyData = await StatsService.getWeeklyTotal(_allExercises, _currentWeekStart);
      double total = 0;
      double best = 0;
      int active = 0;
      for (final val in _weeklyData.values) {
        total += val;
        if (val > best) best = val;
        if (val > 0) active++;
      }
      _totalWeekValue = total;
      _bestDayInWeek = best;
      _activeDaysInWeek = active;
    } else {
      _monthlyData = await StatsService.getMonthlyTotal(_allExercises, _currentMonthDate.year, _currentMonthDate.month);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _nextPeriod() {
    setState(() {
      if (_isWeekly) {
        _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      } else {
        _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month + 1, 1);
      }
    });
    _loadData();
  }

  void _prevPeriod() {
    setState(() {
      if (_isWeekly) {
        _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
      } else {
        _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month - 1, 1);
      }
    });
    _loadData();
  }

  void _gotoCurrentPeriod() {
    setState(() {
      if (_isWeekly) {
        _currentWeekStart = _getStartOfWeek(DateTime.now());
      } else {
        _currentMonthDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      }
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Telemetry & Stats',
          style: TextStyle(color: textCol, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabToggle(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: _isWeekly ? _buildWeeklyView(isDark) : _buildMonthlyView(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() { _isWeekly = true; });
                _loadData();
              },
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: 14,
                isInset: !_isWeekly,
                glowColor: _isWeekly ? AppColors.neonCyan : null,
                child: Center(
                  child: Text(
                    'WEEKLY TELEMETRY',
                    style: TextStyle(
                      color: _isWeekly
                          ? AppColors.neonCyan
                          : (isDark ? AppColors.textDim : const Color(0xFF64748B)),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() { _isWeekly = false; });
                _loadData();
              },
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: 14,
                isInset: _isWeekly,
                glowColor: !_isWeekly ? AppColors.neonCyan : null,
                child: Center(
                  child: Text(
                    'MONTHLY HEATMAP',
                    style: TextStyle(
                      color: !_isWeekly
                          ? AppColors.neonCyan
                          : (isDark ? AppColors.textDim : const Color(0xFF64748B)),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(bool isDark) {
    String weekRange = '${DateFormat('MMM d').format(_currentWeekStart)} - ${DateFormat('MMM d').format(_currentWeekStart.add(const Duration(days: 6)))}';
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _prevPeriod,
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.neonCyan, size: 28),
            ),
            TextButton(
              onPressed: _gotoCurrentPeriod,
              child: Text(
                weekRange,
                style: TextStyle(color: textCol, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: _nextPeriod,
              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.neonCyan, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WeeklyBarChart(weeklyData: _weeklyData, barColor: AppColors.neonCyan),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Total Volume',
              value: _totalWeekValue.toStringAsFixed(0),
              icon: Icons.functions_rounded,
              color: AppColors.staminaHigh,
            ),
            StatCard(
              title: 'Best Day Record',
              value: _bestDayInWeek.toStringAsFixed(0),
              icon: Icons.star_rounded,
              color: AppColors.staminaMid,
            ),
            StatCard(
              title: 'Active Days',
              value: '$_activeDaysInWeek / 7',
              icon: Icons.event_available_rounded,
              color: AppColors.neonCyan,
            ),
            StatCard(
              title: 'Daily Average',
              value: (_totalWeekValue / 7).toStringAsFixed(1),
              icon: Icons.speed_rounded,
              color: AppColors.runColor,
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMonthlyView(bool isDark) {
    String monthStr = DateFormat('MMMM yyyy').format(_currentMonthDate);
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _prevPeriod,
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.neonCyan, size: 28),
            ),
            TextButton(
              onPressed: _gotoCurrentPeriod,
              child: Text(
                monthStr,
                style: TextStyle(color: textCol, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: _nextPeriod,
              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.neonCyan, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ActivityHeatmap(
          monthlyData: _monthlyData,
          year: _currentMonthDate.year,
          month: _currentMonthDate.month,
        ),
        const SizedBox(height: 20),
        MonthlySummary(
          exercises: _allExercises,
          year: _currentMonthDate.year,
          month: _currentMonthDate.month,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
