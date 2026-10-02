import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import '../../data/models/exercise.dart';
import '../../data/exercise_service.dart';
import '../../../../core/services/storage_service.dart';
import '../widgets/exercise_badge_icon.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  double _todayValue = 0;
  List<double> _weekData = List.filled(7, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final val = await ExerciseService.getTodayValue(widget.exercise);
    final weekStart = StorageService.getWeekStart(DateTime.now());
    final weekMap = await StorageService.getWeeklyExerciseData(widget.exercise, weekStart);
    final weekList = List.generate(7, (i) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      return weekMap[date] ?? 0.0;
    });

    if (mounted) {
      setState(() {
        _todayValue = val;
        _weekData = weekList;
        _isLoading = false;
      });
    }
  }

  Future<void> _addValue(double amount) async {
    await ExerciseService.addToday(widget.exercise, amount);
    _loadData();
  }

  Future<void> _resetValue() async {
    await StorageService.resetExercise(widget.exercise, DateTime.now());
    _loadData();
  }

  void _showManualEntryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatted = _todayValue.truncateToDouble() == _todayValue
        ? _todayValue.toInt().toString()
        : _todayValue.toStringAsFixed(1);
    final ctrl = TextEditingController(text: formatted);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Calibrate ${widget.exercise.name}',
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
            decoration: InputDecoration(
              labelText: 'Total ${widget.exercise.unit}',
              labelStyle: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.exercise.accentColor, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.exercise.accentColor,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val != null) {
                  await ExerciseService.logValue(widget.exercise, val);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                }
              },
              child: const Text('Save Calibration'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);
    final accent = widget.exercise.accentColor;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.exercise.name,
          style: TextStyle(color: textCol, fontWeight: FontWeight.w800),
        ),
        iconTheme: IconThemeData(color: textCol),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Exercise Custom Hardware Glyph Badge
                  ExerciseBadgeIcon(
                    exerciseId: widget.exercise.id,
                    fallbackIcon: widget.exercise.icon,
                    accentColor: accent,
                    size: 72,
                    isSelected: true,
                  ),
                  const SizedBox(height: 16),
                  // Central Dial (Rotary deck counter)
                  GestureDetector(
                    onTap: _showManualEntryDialog,
                    child: NeumorphicContainer(
                      width: 210,
                      height: 210,
                      isCircle: true,
                      glowColor: accent,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _todayValue.truncateToDouble() == _todayValue
                                  ? _todayValue.toInt().toString()
                                  : _todayValue.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: accent,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              widget.exercise.unit.toUpperCase(),
                              style: TextStyle(
                                color: subCol,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to adjust',
                              style: TextStyle(
                                color: subCol.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Quick Increment tactile deck buttons
                  Text(
                    'QUICK LOGGING',
                    style: TextStyle(
                      color: subCol,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAdd(1, isDark),
                      _buildQuickAdd(5, isDark),
                      _buildQuickAdd(10, isDark),
                      _buildQuickAdd(25, isDark),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Reset Button
                  OutlinedButton.icon(
                    onPressed: _resetValue,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Today'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.situpColor,
                      side: const BorderSide(color: AppColors.situpColor),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 7-Day Deck Waveform / Bars
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '7-DAY PERFORMANCE',
                      style: TextStyle(
                        color: subCol,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  NeumorphicContainer(
                    isInset: true,
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final value = _weekData[index];
                          final maxVal = _weekData.fold(0.0, (a, b) => a > b ? a : b);
                          final height = maxVal == 0 ? 0.0 : (value / maxVal) * 90.0;
                          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 18,
                                height: height.clamp(4.0, 90.0),
                                decoration: BoxDecoration(
                                  color: value > 0
                                      ? accent
                                      : (isDark ? const Color(0xFF1E2535) : const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: value > 0
                                      ? [
                                          BoxShadow(
                                            color: accent.withValues(alpha: 0.5),
                                            blurRadius: 6,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                days[index],
                                style: TextStyle(
                                  color: subCol,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAdd(int amount, bool isDark) {
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);

    return NeumorphicButton(
      onPressed: () => _addValue(amount.toDouble()),
      size: 58,
      isCircular: true,
      child: Text(
        '+$amount',
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
