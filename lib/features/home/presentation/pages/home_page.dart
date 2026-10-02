import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/exercise_defaults.dart';
import '../../../../core/services/storage_service.dart';
import '../../../exercises/data/models/exercise.dart';
import '../widgets/greeting_header.dart';
import '../widgets/stamina_ring.dart';
import '../widgets/exercise_summary_card.dart';
import '../../data/stamina_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _staminaPercentage = 0.0;
  List<Exercise> _allExercises = [];
  final Map<String, double> _todayValues = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customExercises = await StorageService.getCustomExercises();
    _allExercises = [...ExerciseDefaults.builtIn, ...customExercises];

    final now = DateTime.now();
    for (var ex in _allExercises) {
      final val = await StorageService.getExerciseValue(ex, now);
      _todayValues[ex.id] = val;
    }

    final stamina = await StaminaService.calculateStamina(_allExercises);

    if (mounted) {
      setState(() {
        _staminaPercentage = stamina;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgCol,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingHeader(),
                const SizedBox(height: 12),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 290),
                    child: StaminaRing(percentage: _staminaPercentage),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Activities",
                        style: TextStyle(
                          color: textCol,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '${_allExercises.length} tracked',
                        style: TextStyle(
                          color: subCol,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 148,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _allExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _allExercises[index];
                      final todayVal = _todayValues[ex.id] ?? 0.0;
                      return ExerciseSummaryCard(
                        exercise: ex,
                        todayValue: todayVal,
                      );
                    },
                  ),
                ),
                if (_staminaPercentage < 50)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF191D28) : const Color(0xFFEDF2F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.staminaLow.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.staminaLow, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Stamina decaying: Log reps today to recharge!',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
