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

  const DeckRotaryConsole({
    super.key,
    required this.staminaPercentage,
    this.onQuickAdd,
    this.onResetToday,
    this.onLogFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Flank (3 circular tactile hardware buttons)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTactileKey('+1', () => onQuickAdd?.call(1), isDark),
            const SizedBox(height: 16),
            _buildTactileKey('+5', () => onQuickAdd?.call(5), isDark),
            const SizedBox(height: 16),
            _buildTactileKey('+10', () => onQuickAdd?.call(10), isDark),
          ],
        ),

        // Center Dial (The Mega Hardware Rotary Wheel)
        Container(
          width: 250,
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: StaminaRing(percentage: staminaPercentage),
        ),

        // Right Flank (3 circular buttons with glowing cyan icons)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlowKey(Icons.play_arrow_rounded, onLogFavorite, true),
            const SizedBox(height: 16),
            _buildGlowKey(Icons.fast_forward_rounded, () => onQuickAdd?.call(25), false),
            const SizedBox(height: 16),
            _buildGlowKey(Icons.refresh_rounded, onResetToday, false),
          ],
        ),
      ],
    );
  }

  Widget _buildTactileKey(String label, VoidCallback? onTap, bool isDark) {
    return NeumorphicButton(
      size: 46,
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
    );
  }

  Widget _buildGlowKey(IconData icon, VoidCallback? onTap, bool isPrimary) {
    return NeumorphicButton(
      size: 46,
      isCircular: true,
      glowColor: isPrimary ? AppColors.neonCyan : null,
      onPressed: onTap ?? () {},
      child: Icon(
        icon,
        size: 20,
        color: isPrimary ? AppColors.neonCyan : AppColors.neonCyan.withValues(alpha: 0.7),
      ),
    );
  }
}
