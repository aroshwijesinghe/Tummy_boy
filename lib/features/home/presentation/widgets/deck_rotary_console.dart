import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import 'stamina_ring.dart';

/// Central hardware console housing the rotary stamina wheel flanked by tactile deck buttons,
/// perfectly matching the centerpiece of the reference audio-deck image.
class DeckRotaryConsole extends StatelessWidget {
  final double staminaPercentage;
  final ValueChanged<int>? onQuickAdd;
  final VoidCallback? onResetToday;
  final VoidCallback? onLogFavorite;
  final VoidCallback? onStaminaInfo;

  const DeckRotaryConsole({
    super.key,
    required this.staminaPercentage,
    this.onQuickAdd,
    this.onResetToday,
    this.onLogFavorite,
    this.onStaminaInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Flank (Quick Add Reps with clear labels)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTactileKey('+1', 'Add 1', () => onQuickAdd?.call(1), isDark),
            const SizedBox(height: 12),
            _buildTactileKey('+5', 'Add 5', () => onQuickAdd?.call(5), isDark),
            const SizedBox(height: 12),
            _buildTactileKey('+10', 'Add 10', () => onQuickAdd?.call(10), isDark),
          ],
        ),

        // Center Dial (The Mega Hardware Rotary Wheel)
        Container(
          width: 240,
          height: 240,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: StaminaRing(
            percentage: staminaPercentage,
            onCenterTap: onStaminaInfo,
          ),
        ),

        // Right Flank (Quick Actions with clear labels)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlowKey(Icons.play_arrow_rounded, 'Log Reps', onLogFavorite, true, isDark),
            const SizedBox(height: 12),
            _buildGlowKey(Icons.fast_forward_rounded, 'Add 25', () => onQuickAdd?.call(25), false, isDark),
            const SizedBox(height: 12),
            _buildGlowKey(Icons.refresh_rounded, 'Reset', onResetToday, false, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildTactileKey(String label, String caption, VoidCallback? onTap, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicButton(
          size: 44,
          isCircular: true,
          onPressed: onTap ?? () {},
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          caption,
          style: TextStyle(
            color: isDark ? AppColors.textDim : const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGlowKey(IconData icon, String caption, VoidCallback? onTap, bool isPrimary, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicButton(
          size: 44,
          isCircular: true,
          glowColor: isPrimary ? AppColors.neonCyan : null,
          onPressed: onTap ?? () {},
          child: Icon(
            icon,
            size: 19,
            color: isPrimary ? AppColors.neonCyan : AppColors.neonCyan.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          caption,
          style: TextStyle(
            color: isDark ? AppColors.textDim : const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
