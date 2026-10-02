import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../../core/services/storage_service.dart';

class MonthlySummary extends StatelessWidget {
  final List<Exercise> exercises;
  final int year;
  final int month;

  const MonthlySummary({
    super.key,
    required this.exercises,
    required this.year,
    required this.month,
  });

  Future<Map<Exercise, double>> _getMonthlyBreakdown() async {
    final breakdown = <Exercise, double>{};
    final p = await StorageService.prefs;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (final ex in exercises) {
      double total = 0;
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(year, month, i);
        total += p.getDouble(ex.dailyKey(date)) ?? 0;
      }
      if (total > 0) {
        breakdown[ex] = total;
      }
    }
    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY BREAKDOWN',
            style: TextStyle(
              color: textCol,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<Exercise, double>>(
            future: _getMonthlyBreakdown(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No calibrated logs this month',
                      style: TextStyle(color: subCol, fontSize: 13),
                    ),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.entries.map((entry) {
                  final formattedVal = entry.value.truncateToDouble() == entry.value
                      ? entry.value.toInt().toString()
                      : entry.value.toStringAsFixed(1);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: entry.key.accentColor.withValues(alpha: 0.15),
                          ),
                          child: Icon(entry.key.icon, color: entry.key.accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key.name,
                            style: TextStyle(
                              color: textCol,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '$formattedVal ${entry.key.unit}',
                          style: TextStyle(
                            color: entry.key.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
