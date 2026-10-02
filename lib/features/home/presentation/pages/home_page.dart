import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/exercise_defaults.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/presentation/pages/exercise_detail_page.dart';
import '../../../exercises/presentation/pages/add_custom_exercise_page.dart';
import '../../../exercises/presentation/widgets/exercise_badge_icon.dart';
import '../widgets/stamina_ring.dart';
import '../widgets/stamina_info_dialog.dart';
import '../../data/stamina_service.dart';

/// Clean, simple, easy-to-use and intuitive Home Dashboard.
/// Keeps the hard-neumorphic aesthetic without the confusing cluster of buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _staminaPercentage = 0.0;
  int _streak = 0;
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

    final p = await StorageService.prefs;
    final now = DateTime.now();
    for (final ex in _allExercises) {
      _todayValues[ex.id] = p.getDouble(ex.dailyKey(now)) ?? 0;
    }

    final results = await Future.wait([
      StaminaService.calculateStamina(_allExercises),
      StaminaService.getStreak(_allExercises),
    ]);

    if (mounted) {
      setState(() {
        _staminaPercentage = results[0] as double;
        _streak = results[1] as int;
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
                // 1. SIMPLE & CLEAN HEADER (Greeting, Streak Badge, Theme Switch)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: textCol,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                    // Action controls: Stamina Info button & Theme toggle
                    Row(
                      children: [
                        // Stamina Guide Button
                        GestureDetector(
                          onTap: _showStaminaInfo,
                          child: const NeumorphicContainer(
                            width: 44,
                            height: 44,
                            isCircle: true,
                            padding: EdgeInsets.zero,
                            glowColor: AppColors.neonCyan,
                            child: Center(
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 22,
                                color: AppColors.neonCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dark / Light Theme Toggle
                        ListenableBuilder(
                          listenable: ThemeController.instance,
                          builder: (context, _) {
                            final isCurrentDark = ThemeController.instance.isDarkMode;
                            return GestureDetector(
                              onTap: () => ThemeController.instance.toggleTheme(),
                              child: NeumorphicContainer(
                                width: 44,
                                height: 44,
                                isCircle: true,
                                padding: EdgeInsets.zero,
                                glowColor: isCurrentDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                                child: Center(
                                  child: Icon(
                                    isCurrentDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                    size: 22,
                                    color: isCurrentDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. HERO STAMINA DIAL (Clear, Centered, Tappable with helpful guide)
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: StaminaRing(
                      percentage: _staminaPercentage,
                      onCenterTap: _showStaminaInfo,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Subtitle explanation banner
                Center(
                  child: GestureDetector(
                    onTap: _showStaminaInfo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.bgInputDark.withValues(alpha: 0.6)
                            : AppColors.bgInputLight.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.neonCyan),
                          const SizedBox(width: 6),
                          Text(
                            '-10% if missed day • +14.3% (+100/7%) per workout',
                            style: TextStyle(
                              color: subCol,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 3. EXERCISES SECTION HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR EXERCISES',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddCustomExercisePage()),
                        ).then((_) => _loadData());
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.neonCyan),
                          SizedBox(width: 4),
                          Text(
                            'Add Custom',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 4. CLEAN EXERCISES LIST (Tap any card to adjust, log, or view stats)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allExercises.length,
                  itemBuilder: (context, index) {
                    final ex = _allExercises[index];
                    final todayVal = _todayValues[ex.id] ?? 0.0;
                    final formattedValue = todayVal.truncateToDouble() == todayVal
                        ? todayVal.toInt().toString()
                        : todayVal.toStringAsFixed(1);

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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // Custom Exercise Glyph Badge
                            ExerciseBadgeIcon(
                              exerciseId: ex.id,
                              fallbackIcon: ex.icon,
                              accentColor: ex.accentColor,
                              size: 48,
                              showGlow: true,
                            ),
                            const SizedBox(width: 16),
                            // Name & Unit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: TextStyle(
                                      color: textCol,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Logged Today: $formattedValue ${ex.unit}',
                                    style: TextStyle(
                                      color: todayVal > 0 ? ex.accentColor : subCol,
                                      fontSize: 12.5,
                                      fontWeight: todayVal > 0 ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick +1 button directly on the card
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
                                      content: Text('+$addAmt ${ex.unit} logged for ${ex.name}!'),
                                      backgroundColor: AppColors.neonCyan,
                                      duration: const Duration(milliseconds: 900),
                                    ),
                                  );
                                }
                              },
                              child: NeumorphicContainer(
                                width: 40,
                                height: 40,
                                isCircle: true,
                                padding: EdgeInsets.zero,
                                glowColor: ex.accentColor,
                                child: Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: ex.accentColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: subCol.withValues(alpha: 0.6),
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
