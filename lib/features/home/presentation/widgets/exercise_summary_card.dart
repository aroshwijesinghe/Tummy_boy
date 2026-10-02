import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/presentation/widgets/exercise_badge_icon.dart';

class ExerciseSummaryCard extends StatelessWidget {
  final Exercise exercise;
  final double todayValue;

  const ExerciseSummaryCard({
    super.key,
    required this.exercise,
    required this.todayValue,
  });

  String _formatValue(double val, String unit) {
    if (unit == 'km') return val.toStringAsFixed(1);
    return val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: NeumorphicContainer(
        width: 140,
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseBadgeIcon(
              exerciseId: exercise.id,
              fallbackIcon: exercise.icon,
              accentColor: exercise.accentColor,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              exercise.name,
              style: TextStyle(
                color: textCol,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatValue(todayValue, exercise.unit)} ${exercise.unit}',
              style: TextStyle(
                color: exercise.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
