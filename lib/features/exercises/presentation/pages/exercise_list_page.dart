import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/glow_icon.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../data/models/exercise.dart';
import '../../data/exercise_service.dart';
import '../widgets/exercise_card.dart';
import 'exercise_detail_page.dart';
import 'add_custom_exercise_page.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  List<Exercise> _builtIn = [];
  List<Exercise> _custom = [];
  final Map<String, double> _todayValues = {};
  Set<String> _activeIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = await ExerciseService.getAllExercises();
    final activeList = await StorageService.getActiveExerciseIds();
    final p = await StorageService.prefs;
    final now = DateTime.now();

    _builtIn = all.where((e) => e.isBuiltIn).toList();
    _custom = all.where((e) => !e.isBuiltIn).toList();
    _activeIds = activeList.toSet();

    for (final exercise in all) {
      _todayValues[exercise.id] = p.getDouble(exercise.dailyKey(now)) ?? 0;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleToggleActive(Exercise exercise, bool shouldActivate) async {
    if (shouldActivate) {
      // Check if user already has a goal defined for this exercise
      final currentGoal = await StorageService.getGoal(exercise);
      if (currentGoal == null || currentGoal <= 0) {
        // Prompt user to define a goal for this exercise before enabling it
        if (!mounted) return;
        final saved = await _showGoalPromptDialog(exercise);
        if (!saved) {
          // If cancelled without setting goal, do not activate
          return;
        }
      }
      await StorageService.toggleExerciseActive(exercise.id, true);
    } else {
      await StorageService.toggleExerciseActive(exercise.id, false);
    }
    await _loadData();
  }

  Future<bool> _showGoalPromptDialog(Exercise exercise) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSuggested = exercise.unit == 'km' ? '3' : (exercise.unit == 'seconds' ? '60' : '30');
    final ctrl = TextEditingController(text: defaultSuggested);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.flag_rounded, color: exercise.accentColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Set ${exercise.name} Goal',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Define your daily target before adding this exercise to your Home screen:',
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
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Daily Target (${exercise.unit})',
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
              onPressed: () => Navigator.pop(ctx, false),
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
                  if (ctx.mounted) Navigator.pop(ctx, true);
                }
              },
              child: const Text('Save & Enable'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _confirmDeleteCustomExercise(Exercise exercise) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${exercise.name}?', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
        content: Text(
          'This exercise will be removed from your workout catalog and Home deck. All past logs and metrics for this exercise will remain safely preserved in your Statistics.',
          style: TextStyle(color: isDark ? AppColors.textSecondary : const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.situpColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Module'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await StorageService.removeCustomExercise(exercise.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} removed (historical metrics preserved)'),
            backgroundColor: AppColors.neonCyan,
          ),
        );
      }
    }
  }

  void _navigateToDetail(Exercise exercise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(exercise: exercise),
      ),
    );
    _loadData();
  }

  void _navigateToAddCustom() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomExercisePage(),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Workout Catalog',
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonCyan))
          : RefreshIndicator(
              color: AppColors.neonCyan,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  // Instruction Card
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppColors.neonCyan, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Toggle exercises below to assign them to your Home screen deck and daily goal tracking.',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'BUILT-IN EXERCISES',
                    style: TextStyle(
                      color: subCol,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._builtIn.map((e) => ExerciseCard(
                        exercise: e,
                        todayValue: _todayValues[e.id] ?? 0.0,
                        isActive: _activeIds.contains(e.id),
                        onToggleActive: (val) => _handleToggleActive(e, val),
                        onTap: () => _navigateToDetail(e),
                      )),
                  const SizedBox(height: 20),
                  Text(
                    'CUSTOM MODULES',
                    style: TextStyle(
                      color: subCol,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._custom.map((e) => ExerciseCard(
                        exercise: e,
                        todayValue: _todayValues[e.id] ?? 0.0,
                        isActive: _activeIds.contains(e.id),
                        onToggleActive: (val) => _handleToggleActive(e, val),
                        onDelete: () => _confirmDeleteCustomExercise(e),
                        onTap: () => _navigateToDetail(e),
                      )),
                  // Add custom exercise card (hard debossed socket with neon dashed border)
                  GestureDetector(
                    onTap: _navigateToAddCustom,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24, top: 4),
                      child: NeumorphicContainer(
                        isInset: true,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neonCyan.withValues(alpha: 0.15),
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.neonCyan, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Add Custom Exercise',
                              style: TextStyle(
                                color: isDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? const Color(0xFF191D28) : const Color(0xFFEDF2F9),
        elevation: 4,
        onPressed: _navigateToAddCustom,
        child: const GlowIcon(
          icon: Icons.add_rounded,
          color: AppColors.neonCyan,
          size: 26,
          glowRadius: 10,
        ),
      ),
    );
  }
}
