import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../data/models/exercise.dart';
import 'exercise_badge_icon.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final double todayValue;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.todayValue,
    required this.onTap,
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
              size: 52,
            ),
            const SizedBox(width: 16),
            // Exercise Title and stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: textCol,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
