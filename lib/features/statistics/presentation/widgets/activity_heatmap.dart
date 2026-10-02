import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

class ActivityHeatmap extends StatelessWidget {
  final Map<DateTime, double> monthlyData;
  final int year;
  final int month;

  const ActivityHeatmap({
    super.key,
    required this.monthlyData,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    DateTime firstDay = DateTime(year, month, 1);
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int firstWeekday = firstDay.weekday;

    List<Widget> dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
      return Center(
        child: Text(
          day,
          style: TextStyle(color: subCol, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );
    }).toList();

    List<Widget> cells = [];

    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox(width: 28, height: 28));
    }

    double maxValue = 0;
    if (monthlyData.isNotEmpty) {
      maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    }

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      double value = monthlyData[date] ?? 0;
      cells.add(_buildHeatmapCell(value, maxValue, isDark));
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(firstDay).toUpperCase(),
                style: TextStyle(
                  color: textCol,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Intensity Grid',
                style: TextStyle(color: subCol, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              ...dayHeaders,
              ...cells,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(double value, double maxValue, bool isDark) {
    Color cellColor = isDark ? const Color(0xFF0F121A) : const Color(0xFFD3DBE7);
    if (value > 0 && maxValue > 0) {
      double intensity = value / maxValue;
      if (intensity < 0.3) {
        cellColor = AppColors.neonCyan.withValues(alpha: 0.3);
      } else if (intensity < 0.7) {
        cellColor = AppColors.neonCyan.withValues(alpha: 0.65);
      } else {
        cellColor = AppColors.neonCyan;
      }
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2535) : const Color(0xFFCAD5E2),
          width: 0.5,
        ),
        boxShadow: value > 0
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.25),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}
