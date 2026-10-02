import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_button.dart';

import '../../../exercises/presentation/widgets/exercise_badge_icon.dart';

/// Bottom audio-deck console with 2x2 left circular presets, 4 center hardware pills,
/// and 2x2 right circular presets matching the bottom half of the reference image.
class DeckBottomConsole extends StatelessWidget {
  final ValueChanged<String>? onPresetSelected;
  final ValueChanged<int>? onRepsAdjusted;

  const DeckBottomConsole({
    super.key,
    this.onPresetSelected,
    this.onRepsAdjusted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left 2x2 Preset Matrix
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildExerciseKey('pushups', Icons.fitness_center_rounded, AppColors.pushupColor),
                  const SizedBox(width: 12),
                  _buildExerciseKey('squats', Icons.accessibility_new, AppColors.squatColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildExerciseKey('jumping_jacks', Icons.sports_martial_arts, AppColors.jumpColor),
                  const SizedBox(width: 12),
                  _buildExerciseKey('planks', Icons.self_improvement, AppColors.plankColor),
                ],
              ),
            ],
          ),

          // Center 4 Small Hardware Channel Buttons (CH+, CH-, VOL-, VOL+ style)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniPill('REP+', () => onRepsAdjusted?.call(5), isDark),
              const SizedBox(width: 6),
              _buildMiniPill('REP-', () => onRepsAdjusted?.call(-5), isDark),
              const SizedBox(width: 6),
              _buildMiniPill('CAL+', () => onRepsAdjusted?.call(10), isDark),
              const SizedBox(width: 6),
              _buildMiniPill('RST', () => onRepsAdjusted?.call(0), isDark),
            ],
          ),

          // Right 2x2 Preset Matrix
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildExerciseKey('running', Icons.directions_run_rounded, AppColors.runColor),
                  const SizedBox(width: 12),
                  _buildExerciseKey('situps', Icons.airline_seat_flat, AppColors.situpColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDeckWireframeKey(Icons.tune_rounded, () => onPresetSelected?.call('custom')),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.info_outline_rounded, () => onPresetSelected?.call('telemetry')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseKey(String exerciseId, IconData fallback, Color color) {
    return GestureDetector(
      onTap: () => onPresetSelected?.call(exerciseId),
      child: ExerciseBadgeIcon(
        exerciseId: exerciseId,
        fallbackIcon: fallback,
        accentColor: color,
        size: 44,
        showGlow: true,
      ),
    );
  }

  Widget _buildDeckWireframeKey(IconData icon, VoidCallback onTap) {
    return NeumorphicButton(
      size: 44,
      isCircular: true,
      glowColor: AppColors.neonCyan,
      onPressed: onTap,
      child: Icon(
        icon,
        size: 19,
        color: AppColors.neonCyan,
      ),
    );
  }

  Widget _buildMiniPill(String label, VoidCallback onTap, bool isDark) {
    return NeumorphicButton(
      size: 34,
      isCircular: true,
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.textDim : const Color(0xFF64748B),
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
