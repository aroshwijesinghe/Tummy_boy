import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

/// Modal dialog providing a clear, interactive explanation of how the Stamina System works,
/// matching the hard-neumorphic dark/light deck design.
class StaminaInfoDialog extends StatelessWidget {
  final double currentStamina;
  final int streakDays;

  const StaminaInfoDialog({
    super.key,
    required this.currentStamina,
    required this.streakDays,
  });

  static Future<void> show(BuildContext context, {required double stamina, required int streak}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => StaminaInfoDialog(
        currentStamina: stamina,
        streakDays: streak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final dimCol = isDark ? AppColors.textDim : const Color(0xFF94A3B8);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: NeumorphicContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Title & Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.battery_charging_full_rounded,
                      color: AppColors.neonCyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STAMINA SYSTEM',
                          style: TextStyle(
                            color: textCol,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dynamic Energy & Streak Engine',
                          style: TextStyle(
                            color: subCol,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeumorphicButton(
                    size: 36,
                    isCircular: true,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded, size: 18, color: subCol),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Live Status Banner
              NeumorphicContainer(
                isInset: true,
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusMetric(
                      label: 'CURRENT STAMINA',
                      value: '${currentStamina.toInt()}%',
                      valueColor: currentStamina >= 80
                          ? AppColors.neonCyan
                          : currentStamina >= 50
                              ? AppColors.staminaMid
                              : AppColors.staminaLow,
                      dimCol: dimCol,
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    _buildStatusMetric(
                      label: 'ACTIVE STREAK',
                      value: '$streakDays ${streakDays == 1 ? "Day" : "Days"}',
                      valueColor: AppColors.neonCyan,
                      dimCol: dimCol,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rule 1: Goal Progress Driven Stamina
              _buildRuleCard(
                icon: Icons.electric_bolt_rounded,
                iconColor: AppColors.neonCyan,
                title: 'Stamina = (100/7)% × Daily Progress',
                description:
                    'Your daily stamina recharge scales directly with your daily goals: (100 / 7)% × (Overall Daily Goal Progress). Reach 100% on your daily goals to earn the full +14.29% stamina boost!',
                isDark: isDark,
                textCol: textCol,
                subCol: subCol,
              ),

              const SizedBox(height: 12),

              // Rule 2: Natural Decay (Missed days)
              _buildRuleCard(
                icon: Icons.trending_down_rounded,
                iconColor: AppColors.staminaLow,
                title: 'Missed Day = -10% Penalty',
                description:
                    'If you do not exercise for a day, your stamina automatically drops down by -10%. Consecutive missed days continue to decrease stamina until 0%.',
                isDark: isDark,
                textCol: textCol,
                subCol: subCol,
              ),

              const SizedBox(height: 12),

              // Rule 3: Customizable Goals
              _buildRuleCard(
                icon: Icons.flag_rounded,
                iconColor: AppColors.staminaMid,
                title: 'Customizable Exercise Goals',
                description:
                    'Set your own target count for each exercise (e.g., 30 pushups, 3 km run). As you log exercises, their individual progress bars fill up and boost your overall day progress bar!',
                isDark: isDark,
                textCol: textCol,
                subCol: subCol,
              ),

              const SizedBox(height: 12),

              // Rule 4: Streak bonus
              _buildRuleCard(
                icon: Icons.speed_rounded,
                iconColor: AppColors.squatColor,
                title: 'Active Consistency Bonus',
                description:
                    'Maintain your daily workout streak to build resilience against decay and lock your energy gauge into overdrive.',
                isDark: isDark,
                textCol: textCol,
                subCol: subCol,
              ),

              const SizedBox(height: 22),

              // Understood / Close Action Button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const NeumorphicContainer(
                  height: 48,
                  borderRadius: 24,
                  glowColor: AppColors.neonCyan,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: AppColors.neonCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'GOT IT',
                          style: TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMetric({
    required String label,
    required String value,
    required Color valueColor,
    required Color dimCol,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: dimCol,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
    required Color textCol,
    required Color subCol,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgInputDark.withValues(alpha: 0.5) : AppColors.bgInputLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textCol,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: subCol,
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
