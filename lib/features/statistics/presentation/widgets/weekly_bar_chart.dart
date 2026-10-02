import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<DateTime, double> weeklyData;
  final Color barColor;

  const WeeklyBarChart({
    super.key,
    required this.weeklyData,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);
    final trackCol = isDark ? const Color(0xFF0F121A) : const Color(0xFFD3DBE7);
    final gridCol = isDark ? const Color(0xFF242C3D) : const Color(0xFFCBD5E1);

    List<BarChartGroupData> barGroups = [];
    int i = 0;

    var keys = weeklyData.keys.toList()..sort();

    for (var date in keys) {
      final val = weeklyData[date] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              gradient: LinearGradient(
                colors: [barColor, barColor.withValues(alpha: 0.6)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxY(weeklyData.values),
                color: trackCol,
              ),
            ),
          ],
        ),
      );
      i++;
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
                'ACTIVITY TELEMETRY',
                style: TextStyle(
                  color: textCol,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Daily Output',
                  style: TextStyle(
                    color: barColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(weeklyData.values),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= keys.length) return const SizedBox.shrink();
                        final date = keys[value.toInt()];
                        final dayStr = DateFormat('E').format(date).substring(0, 3);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dayStr,
                            style: TextStyle(
                              color: subCol,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: subCol,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: gridCol.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(Iterable<double> values) {
    if (values.isEmpty) return 10;
    double max = values.reduce((curr, next) => curr > next ? curr : next);
    return max < 10 ? 10 : max * 1.2;
  }
}
