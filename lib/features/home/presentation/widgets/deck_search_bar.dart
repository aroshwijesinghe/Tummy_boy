import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_button.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

/// Top-center deck search bar and hardware mode pill buttons matching the reference image.
class DeckSearchAndModeConsole extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<int>? onModeSelected;
  final int selectedMode;

  const DeckSearchAndModeConsole({
    super.key,
    this.onSearchChanged,
    this.onModeSelected,
    this.selectedMode = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Inset Debossed Search Capsule (matching reference image top-center)
        NeumorphicContainer(
          width: double.infinity,
          height: 48,
          isInset: true,
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: subCol, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Telemetry | Search',
                  style: TextStyle(
                    color: subCol,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Glowing Neon Cyan status LED (matching image right dot)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.9),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Row of 4 Circular Hardware Buttons (matching reference image under search)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDeckKey(0, Icons.grid_view_rounded, isDark),
            _buildDeckKey(1, Icons.fitness_center_rounded, isDark),
            _buildDeckKey(2, Icons.directions_run_rounded, isDark),
            _buildDeckKey(3, Icons.timer_outlined, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildDeckKey(int index, IconData icon, bool isDark) {
    final isSelected = selectedMode == index;

    return NeumorphicButton(
      size: 40,
      isCircular: true,
      glowColor: isSelected ? AppColors.neonCyan : null,
      onPressed: () => onModeSelected?.call(index),
      child: Icon(
        icon,
        size: 18,
        color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.textDim : const Color(0xFF94A3B8)),
      ),
    );
  }
}
