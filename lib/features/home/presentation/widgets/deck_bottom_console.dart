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
                  _buildExerciseKey('pushups', 'Pushups', Icons.fitness_center_rounded, AppColors.pushupColor, isDark),
                  const SizedBox(width: 12),
                  _buildExerciseKey('squats', 'Squats', Icons.accessibility_new, AppColors.squatColor, isDark),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildExerciseKey('jumping_jacks', 'Jacks', Icons.sports_martial_arts, AppColors.jumpColor, isDark),
                  const SizedBox(width: 12),
                  _buildExerciseKey('planks', 'Planks', Icons.self_improvement, AppColors.plankColor, isDark),
                ],
              ),
            ],
          ),

          // Center 4 Small Hardware Channel Buttons (Quick adjust pills with labels)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniPill('REP+', () => onRepsAdjusted?.call(5), isDark),
                  const SizedBox(width: 6),
                  _buildMiniPill('REP-', () => onRepsAdjusted?.call(-5), isDark),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniPill('CAL+', () => onRepsAdjusted?.call(10), isDark),
                  const SizedBox(width: 6),
                  _buildMiniPill('RST', () => onRepsAdjusted?.call(0), isDark),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'QUICK TUNE',
                style: TextStyle(
                  color: isDark ? AppColors.textDim : const Color(0xFF94A3B8),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Right 2x2 Preset Matrix
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildExerciseKey('running', 'Run', Icons.directions_run_rounded, AppColors.runColor, isDark),
                  const SizedBox(width: 12),
                  _buildExerciseKey('situps', 'Situps', Icons.airline_seat_flat, AppColors.situpColor, isDark),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildDeckWireframeKey(Icons.tune_rounded, 'Custom', () => onPresetSelected?.call('custom'), isDark),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.info_outline_rounded, 'Guide', () => onPresetSelected?.call('telemetry'), isDark),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseKey(String exerciseId, String name, IconData fallback, Color color, bool isDark) {
    return GestureDetector(
      onTap: () => onPresetSelected?.call(exerciseId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExerciseBadgeIcon(
            exerciseId: exerciseId,
            fallbackIcon: fallback,
            accentColor: color,
            size: 44,
            showGlow: true,
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 48,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.textDim : const Color(0xFF64748B),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckWireframeKey(IconData icon, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeumorphicButton(
            size: 44,
            isCircular: true,
            glowColor: AppColors.neonCyan,
            onPressed: onTap,
            child: Icon(
              icon,
              size: 19,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.textDim : const Color(0xFF64748B),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
