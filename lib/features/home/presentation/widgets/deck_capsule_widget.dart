import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

/// Top-left debossed capsule with glowing star/trophy, telemetry label, and animated equalizer bars.
class DeckTelemetryCapsule extends StatefulWidget {
  final double stamina;
  final VoidCallback? onInfoTap;

  const DeckTelemetryCapsule({
    super.key,
    required this.stamina,
    this.onInfoTap,
  });

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

    return NeumorphicContainer(
      width: 78,
      height: 165,
      isInset: true,
      borderRadius: 36,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Raised circular info/star button (matching reference image top-left, taps to show stamina guide)
          GestureDetector(
            onTap: widget.onInfoTap,
            child: const NeumorphicContainer(
              width: 44,
              height: 44,
              isCircle: true,
              padding: EdgeInsets.zero,
              glowColor: AppColors.neonCyan,
              child: Center(
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: AppColors.neonCyan,
                ),
              ),
            ),
          ),
          // Helpful Label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'STAMINA',
                style: TextStyle(
                  color: textCol,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Text(
                'GUIDE',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Animated Electric Cyan Waveform Equalizer (matching image audio lines)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return SizedBox(
                width: 58,
                height: 20,
                child: CustomPaint(
                  painter: _EqualizerPainter(_animController.value),
                ),
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
          // Center Theme / Mode Label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'THEME',
                style: TextStyle(
                  color: textCol,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                activeStreak > 0 ? '$activeStreak D STREAK' : 'DAILY STREAK',
                style: TextStyle(
                  color: activeStreak > 0 ? AppColors.neonCyan : subCol,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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

class _EqualizerPainter extends CustomPainter {
  final double progress;
  _EqualizerPainter(this.progress);

  static final _paint = Paint()
    ..color = AppColors.neonCyan
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 9;
    final totalSpacing = size.width - (barCount * 2.5);
    final spacing = totalSpacing / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final wave = ((i % 3 + 1) * 0.25) + (progress * 0.5);
      final barHeight = (6.0 + (wave * 12.0)).clamp(4.0, size.height);
      final left = i * (2.5 + spacing);
      final top = size.height - barHeight;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, 2.5, barHeight),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(rrect, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
