import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../data/models/exercise.dart';
import 'exercise_badge_icon.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final double todayValue;
  final VoidCallback onTap;
  final bool isActive;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback? onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.todayValue,
    required this.onTap,
    this.isActive = false,
    this.onToggleActive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    final formattedValue = todayValue.truncateToDouble() == todayValue
        ? todayValue.toInt().toString()
        : todayValue.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: NeumorphicContainer(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Tactile extruded round icon button (deck style with proper athletic glyphs)
            ExerciseBadgeIcon(
              exerciseId: exercise.id,
              fallbackIcon: exercise.icon,
              accentColor: exercise.accentColor,
              size: 50,
            ),
            const SizedBox(width: 14),
            // Exercise Title and stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          exercise.name,
                          style: TextStyle(
                            color: textCol,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Today: ',
                        style: TextStyle(color: subCol, fontSize: 13),
                      ),
                      Text(
                        '$formattedValue ${exercise.unit}',
                        style: TextStyle(
                          color: exercise.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button for custom exercises
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.situpColor.withValues(alpha: 0.7),
                tooltip: 'Delete custom exercise',
                onPressed: onDelete,
              ),
            // Enable / Disable on Home toggle
            if (onToggleActive != null)
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isActive,
                  activeThumbColor: AppColors.neonCyan,
                  activeTrackColor: AppColors.neonCyan.withValues(alpha: 0.3),
                  inactiveThumbColor: subCol,
                  inactiveTrackColor: isDark ? const Color(0xFF1E2538) : const Color(0xFFD6DFEC),
                  onChanged: onToggleActive,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: subCol,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
