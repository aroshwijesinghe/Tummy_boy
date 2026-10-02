import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

/// Top-left debossed capsule with glowing star/trophy, telemetry label, and animated equalizer bars.
class DeckTelemetryCapsule extends StatefulWidget {
  final double stamina;

  const DeckTelemetryCapsule({super.key, required this.stamina});

  @override
  State<DeckTelemetryCapsule> createState() => _DeckTelemetryCapsuleState();
}

class _DeckTelemetryCapsuleState extends State<DeckTelemetryCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return NeumorphicContainer(
      width: 78,
      height: 165,
      isInset: true,
      borderRadius: 36,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Raised circular star button (matching reference image top-left)
          const NeumorphicContainer(
            width: 44,
            height: 44,
            isCircle: true,
            padding: EdgeInsets.zero,
            glowColor: AppColors.neonCyan,
            child: Center(
              child: Icon(
                Icons.star_rounded,
                size: 24,
                color: AppColors.neonCyan,
              ),
            ),
          ),
          // Telemetry Label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ENERGY',
                style: TextStyle(
                  color: textCol,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'OUTPUT',
                style: TextStyle(
                  color: subCol,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Animated Electric Cyan Waveform Equalizer (matching image audio lines)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              const barCount = 9;
              final val = _animController.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(barCount, (i) {
                  // Generate animated audio bar heights
                  final wave = ((i % 3 + 1) * 0.25) + (val * 0.5);
                  final barHeight = (8.0 + (wave * 12.0)).clamp(4.0, 18.0);
                  return Container(
                    width: 2.5,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Top-right debossed capsule with the Theme dial knob (Sun/Moon) and 3x4 glowing LED matrix.
class DeckThemeCapsule extends StatelessWidget {
  final int activeStreak;

  const DeckThemeCapsule({super.key, required this.activeStreak});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicContainer(
      width: 78,
      height: 165,
      isInset: true,
      borderRadius: 36,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Raised Sun/Moon Dial (matching reference image top-right sun button)
          ListenableBuilder(
            listenable: ThemeController.instance,
            builder: (context, _) {
              final isCurrentDark = ThemeController.instance.isDarkMode;
              return GestureDetector(
                onTap: () => ThemeController.instance.toggleTheme(),
                child: NeumorphicContainer(
                  width: 44,
                  height: 44,
                  isCircle: true,
                  padding: EdgeInsets.zero,
                  glowColor: isCurrentDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                  child: Center(
                    child: Icon(
                      isCurrentDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      size: 22,
                      color: isCurrentDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                    ),
                  ),
                ),
              );
            },
          ),
          // 3x4 Dot Matrix LED Grid (matching reference image bottom of right capsule)
          Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (col) {
                      final dotIndex = row * 3 + col;
                      final isLit = dotIndex <= (activeStreak + 2).clamp(0, 11);
                      return Container(
                        width: 4.5,
                        height: 4.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLit
                              ? AppColors.neonCyan
                              : (isDark ? const Color(0xFF222B3D) : const Color(0xFFCAD5E2)),
                          boxShadow: isLit
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withValues(alpha: 0.8),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
