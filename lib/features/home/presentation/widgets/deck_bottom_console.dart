import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_button.dart';

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
                  _buildDeckWireframeKey(Icons.fitness_center_rounded, () => onPresetSelected?.call('pushups')),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.airline_seat_legroom_extra_rounded, () => onPresetSelected?.call('squats')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDeckWireframeKey(Icons.favorite_border_rounded, () => onPresetSelected?.call('jumping_jacks')),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.horizontal_rule_rounded, () => onPresetSelected?.call('planks')),
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
                  _buildDeckWireframeKey(Icons.directions_run_rounded, () => onPresetSelected?.call('running')),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.sports_gymnastics_rounded, () => onPresetSelected?.call('situps')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDeckWireframeKey(Icons.tune_rounded, () => onPresetSelected?.call('custom')),
                  const SizedBox(width: 12),
                  _buildDeckWireframeKey(Icons.location_searching_rounded, () => onPresetSelected?.call('telemetry')),
                ],
              ),
            ],
          ),
        ],
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
