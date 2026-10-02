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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = await ExerciseService.getAllExercises();
    final p = await StorageService.prefs;
    final now = DateTime.now();

    _builtIn = all.where((e) => e.isBuiltIn).toList();
    _custom = all.where((e) => !e.isBuiltIn).toList();

    for (final exercise in all) {
      _todayValues[exercise.id] = p.getDouble(exercise.dailyKey(now)) ?? 0;
    }

    if (mounted) {
      setState(() => _isLoading = false);
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
          'Workout Modules',
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
                  Text(
                    'CALIBRATED EXERCISES',
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
