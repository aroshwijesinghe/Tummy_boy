import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/exercise_defaults.dart';
import '../../../../core/services/storage_service.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/data/exercise_service.dart';
import '../../../exercises/presentation/pages/exercise_detail_page.dart';
import '../../../exercises/presentation/pages/add_custom_exercise_page.dart';
import '../widgets/deck_capsule_widget.dart';
import '../widgets/deck_search_bar.dart';
import '../widgets/deck_rotary_console.dart';
import '../widgets/deck_bottom_console.dart';
import '../widgets/exercise_summary_card.dart';
import '../../data/stamina_service.dart';

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
  int _selectedFilterMode = 0;
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

  Future<void> _quickAddReps(int amount) async {
    if (_allExercises.isNotEmpty) {
      final defaultEx = _allExercises.first;
      await ExerciseService.addToday(defaultEx, amount.toDouble());
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged +$amount ${defaultEx.unit} for ${defaultEx.name}'),
            backgroundColor: AppColors.neonCyan,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _resetToday() async {
    if (_allExercises.isNotEmpty) {
      final defaultEx = _allExercises.first;
      await StorageService.resetExercise(defaultEx, DateTime.now());
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset ${defaultEx.name} for today'),
            backgroundColor: AppColors.situpColor,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _onPresetTapped(String key) {
    if (key == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddCustomExercisePage()),
      ).then((_) => _loadData());
      return;
    }

    final match = _allExercises.firstWhere(
      (e) => e.id.toLowerCase().contains(key) || key.contains(e.id.toLowerCase()),
      orElse: () => _allExercises.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseDetailPage(exercise: match)),
    ).then((_) => _loadData());
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. TOP AUDIO-DECK CONSOLE (Left Capsule, Center Search/Keys, Right Capsule)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Left Capsule: Glowing Star & Equalizer
                      DeckTelemetryCapsule(stamina: _staminaPercentage),
                      const SizedBox(width: 12),
                      // Top Center Console: Inset Search & 4 Mode buttons
                      Expanded(
                        child: DeckSearchAndModeConsole(
                          selectedMode: _selectedFilterMode,
                          onModeSelected: (m) => setState(() => _selectedFilterMode = m),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Top Right Capsule: Sun/Moon Theme Knob & LED Matrix
                      DeckThemeCapsule(activeStreak: _streak),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. CENTERPIECE (Rotary Dial with Left & Right Flank Keypads)
                DeckRotaryConsole(
                  staminaPercentage: _staminaPercentage,
                  onQuickAdd: _quickAddReps,
                  onResetToday: _resetToday,
                  onLogFavorite: () => _onPresetTapped('pushups'),
                ),

                const SizedBox(height: 28),

                // 3. BOTTOM MIXER CONSOLE (2x2 Wireframes, 4 Channel pills, 2x2 Wireframes)
                DeckBottomConsole(
                  onPresetSelected: _onPresetTapped,
                  onRepsAdjusted: (amt) {
                    if (amt == 0) {
                      _resetToday();
                    } else {
                      _quickAddReps(amt);
                    }
                  },
                ),

                const SizedBox(height: 32),

                // 4. MODULES TELEMETRY SCROLLVIEW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HARDWARE MODULES',
                        style: TextStyle(
                          color: textCol,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${_allExercises.length} Active Channels',
                        style: TextStyle(
                          color: subCol,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 148,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: _allExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _allExercises[index];
                      final todayVal = _todayValues[ex.id] ?? 0.0;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailPage(exercise: ex),
                            ),
                          ).then((_) => _loadData());
                        },
                        child: ExerciseSummaryCard(
                          exercise: ex,
                          todayValue: todayVal,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
