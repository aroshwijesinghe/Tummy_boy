import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/presentation/pages/exercise_detail_page.dart';
import '../../../exercises/presentation/widgets/exercise_badge_icon.dart';
import '../../../exercises/data/exercise_service.dart';
import '../../../exercises/presentation/pages/exercise_list_page.dart';
import '../widgets/stamina_ring.dart';
import '../widgets/stamina_info_dialog.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../data/stamina_service.dart';

/// Clean, simple, and intuitive Home Dashboard with customizable exercise goals,
/// individual exercise progress bars, and an overall daily progress bar scaling stamina gain.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _staminaPercentage = 0.0;
  double _dailyGoalProgress = 0.0;
  int _streak = 0;
  List<Exercise> _allExercises = [];
  final Map<String, double> _todayValues = {};
  final Map<String, double> _goalValues = {};
  bool _isLoading = true;

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
    final activeExercises = await ExerciseService.getActiveExercises();
    _allExercises = activeExercises;

    final p = await StorageService.prefs;
    final now = DateTime.now();
    for (final ex in _allExercises) {
      _todayValues[ex.id] = p.getDouble(ex.dailyKey(now)) ?? 0.0;
      _goalValues[ex.id] = await StorageService.getGoalOrDefault(ex, 0.0);
    }

    final results = await Future.wait([
      StaminaService.calculateStamina(_allExercises),
      StaminaService.getStreak(_allExercises),
      StaminaService.calculateDailyGoalProgress(_allExercises),
    ]);

    if (mounted) {
      setState(() {
        _staminaPercentage = results[0] as double;
        _streak = results[1] as int;
        _dailyGoalProgress = results[2] as double;
        _isLoading = false;
      });
    }
  }

  void _showStaminaInfo() {
    StaminaInfoDialog.show(
      context,
      stamina: _staminaPercentage,
      streak: _streak,
    );
  }

  void _showEditGoalDialog(Exercise exercise) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGoal = _goalValues[exercise.id] ?? 0.0;
    final formattedGoal = currentGoal > 0
        ? (currentGoal.truncateToDouble() == currentGoal
            ? currentGoal.toInt().toString()
            : currentGoal.toStringAsFixed(1))
        : (exercise.unit == 'km' ? '3' : (exercise.unit == 'seconds' ? '60' : '30'));
    final ctrl = TextEditingController(text: formattedGoal);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.flag_rounded, color: exercise.accentColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Edit ${exercise.name} Goal',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your daily target count for ${exercise.name}:',
                style: TextStyle(
                  color: isDark ? AppColors.textDim : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Target (${exercise.unit})',
                  labelStyle: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: exercise.accentColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: exercise.accentColor,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final val = double.tryParse(ctrl.text.trim());
                if (val != null && val > 0) {
                  await StorageService.setGoal(exercise, val);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                }
              },
              child: const Text('Save Goal'),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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

    final double overallPct = (_dailyGoalProgress * 100).clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. SIMPLE & CLEAN HEADER (Greeting & Streak Badge)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: textCol,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: AppColors.neonCyan),
                        const SizedBox(width: 4),
                        Text(
                          _streak > 0 ? '$_streak Day Workout Streak' : 'Daily Fitness Tracker',
                          style: TextStyle(
                            color: _streak > 0 ? AppColors.neonCyan : subCol,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 2. HERO STAMINA DIAL (Centered, Tappable with helpful guide)
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: StaminaRing(
                      percentage: _staminaPercentage,
                      onCenterTap: _showStaminaInfo,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 3. OVERALL DAILY PROGRESS BAR CARD (Driven by individual goals)
                NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.neonCyan, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "TODAY'S OVERALL PROGRESS",
                                style: TextStyle(
                                  color: textCol,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${overallPct.toInt()}%',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Inset Track for Overall Progress
                      NeumorphicContainer(
                        height: 12,
                        isInset: true,
                        borderRadius: 6,
                        padding: EdgeInsets.zero,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _dailyGoalProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00B4D8), AppColors.neonCyan],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stamina Gain Today: +${((100.0 / 7.0) * _dailyGoalProgress).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            overallPct >= 100 ? 'All Goals Met!' : 'Target: 100%',
                            style: TextStyle(
                              color: subCol,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // 4. EXERCISES SECTION HEADER
                Text(
                  'YOUR GOALS & EXERCISES',
                  style: TextStyle(
                    color: textCol,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                // 5. CLEAN EXERCISES LIST WITH GOALS & INDIVIDUAL PROGRESS BARS OR EMPTY STATE
                if (_allExercises.isEmpty)
                  NeumorphicContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonCyan.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: const Icon(Icons.fitness_center_rounded, color: AppColors.neonCyan, size: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Exercises Assigned',
                          style: TextStyle(
                            color: textCol,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose your exercises from the Workout Catalog and define your daily targets to start tracking stamina.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subCol,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExerciseListPage()),
                            ).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.add_task_rounded, size: 18),
                          label: const Text(
                            'Assign Exercises & Set Goals',
                            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _allExercises[index];
                      final todayVal = _todayValues[ex.id] ?? 0.0;
                      final goalVal = _goalValues[ex.id] ?? 0.0;
                      final double progress = goalVal > 0 ? (todayVal / goalVal).clamp(0.0, 1.0) : 0.0;

                      final formattedValue = todayVal.truncateToDouble() == todayVal
                          ? todayVal.toInt().toString()
                          : todayVal.toStringAsFixed(1);
                      final formattedGoal = goalVal > 0
                          ? (goalVal.truncateToDouble() == goalVal
                              ? goalVal.toInt().toString()
                              : goalVal.toStringAsFixed(1))
                          : 'Not set';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: NeumorphicContainer(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailPage(exercise: ex),
                            ),
                          ).then((_) => _loadData());
                        },
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Custom Exercise Glyph Badge
                                ExerciseBadgeIcon(
                                  exerciseId: ex.id,
                                  fallbackIcon: ex.icon,
                                  accentColor: ex.accentColor,
                                  size: 44,
                                  showGlow: true,
                                ),
                                const SizedBox(width: 14),
                                // Name & Progress text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: TextStyle(
                                              color: textCol,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          // Edit Goal Button
                                          GestureDetector(
                                            onTap: () => _showEditGoalDialog(ex),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                              decoration: BoxDecoration(
                                                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.edit_rounded, size: 10, color: subCol),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'Goal: $formattedGoal',
                                                    style: TextStyle(
                                                      color: subCol,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$formattedValue / $formattedGoal ${ex.unit}',
                                            style: TextStyle(
                                              color: todayVal >= goalVal ? ex.accentColor : subCol,
                                              fontSize: 12.5,
                                              fontWeight: todayVal >= goalVal ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${(progress * 100).toInt()}%',
                                            style: TextStyle(
                                              color: ex.accentColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Quick + button directly on the card
                                GestureDetector(
                                  onTap: () async {
                                    final p = await StorageService.prefs;
                                    final key = ex.dailyKey(DateTime.now());
                                    final cur = p.getDouble(key) ?? 0.0;
                                    final addAmt = ex.unit == 'km' ? 0.5 : 5.0;
                                    await p.setDouble(key, cur + addAmt);
                                    await _loadData();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('+$addAmt ${ex.unit} for ${ex.name}!'),
                                          backgroundColor: AppColors.neonCyan,
                                          duration: const Duration(milliseconds: 700),
                                        ),
                                      );
                                    }
                                  },
                                  child: NeumorphicContainer(
                                    width: 38,
                                    height: 38,
                                    isCircle: true,
                                    padding: EdgeInsets.zero,
                                    glowColor: ex.accentColor,
                                    child: Center(
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: ex.accentColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Individual Exercise Progress Bar (fills up as user adds count)
                            NeumorphicContainer(
                              height: 7,
                              isInset: true,
                              borderRadius: 4,
                              padding: EdgeInsets.zero,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ex.accentColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ex.accentColor.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
