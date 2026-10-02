import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// A hard neumorphic rotary dial matching the audio-deck centerpiece in the reference image.
/// Features perimeter indicator dots, debossed circular track, electric neon arc,
/// and a tactile central bevel knob with illuminated status.
class StaminaRing extends StatefulWidget {
  final double percentage;
  final VoidCallback? onCenterTap;

  const StaminaRing({
    super.key,
    required this.percentage,
    this.onCenterTap,
  });

  @override
  State<StaminaRing> createState() => _StaminaRingState();
}

class _StaminaRingState extends State<StaminaRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StaminaRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(begin: _animation.value, end: widget.percentage).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final pct = _animation.value.clamp(0.0, 100.0);
          final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
          final subCol = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _DeckRotaryPainter(
                  percentage: pct,
                  isDark: isDark,
                ),
              ),
              // Central knob display (Tappable to view Stamina explanation)
              GestureDetector(
                onTap: widget.onCenterTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.power_settings_new_rounded,
                            size: 26,
                            color: AppColors.neonCyan,
                          ),
                        ),
                        // Small info badge hinting it is clickable
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.bgCardDark : AppColors.bgCardLight,
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 10,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STAMINA',
                          style: TextStyle(
                            color: subCol,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.help_outline_rounded,
                          size: 11,
                          color: subCol.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pct.toInt()}%',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pct >= 80
                          ? 'Peak Energy'
                          : pct >= 50
                              ? 'Steady Rhythm'
                              : 'Needs Boost',
                      style: TextStyle(
                        color: pct >= 80
                            ? AppColors.neonCyan
                            : pct >= 50
                                ? AppColors.staminaMid
                                : AppColors.staminaLow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeckRotaryPainter extends CustomPainter {
  final double percentage;
  final bool isDark;

  _DeckRotaryPainter({required this.percentage, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (min(size.width, size.height) / 2) - 4;

    // 1. Draw outer perimeter hardware dots (like audio knob indicators)
    final dotRadius = outerRadius - 4;
    final dotPaint = Paint()
      ..color = (isDark ? const Color(0xFF283144) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.fill;

    final activeDotPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: isDark ? 0.8 : 0.6)
      ..style = PaintingStyle.fill;

    const totalDots = 20;
    final activeDotsCount = (percentage / 100 * totalDots).round();

    for (int i = 0; i < totalDots; i++) {
      final angle = (-pi / 2) + (i * 2 * pi / totalDots);
      final dx = center.dx + dotRadius * cos(angle);
      final dy = center.dy + dotRadius * sin(angle);
      final isActive = i <= activeDotsCount;
      canvas.drawCircle(Offset(dx, dy), isActive ? 2.5 : 1.8, isActive ? activeDotPaint : dotPaint);
    }

    // 2. Draw outer debossed trench track
    final trackRadius = outerRadius - 20;
    final trackBgPaint = Paint()
      ..color = isDark ? const Color(0xFF0F121A) : const Color(0xFFD3DBE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, trackRadius, trackBgPaint);

    // 3. Draw active electric neon progress arc
    if (percentage > 0) {
      final rect = Rect.fromCircle(center: center, radius: trackRadius);
      final sweepAngle = (percentage / 100) * 2 * pi;

      // Glow halo
      final glowPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: isDark ? 0.5 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);

      // Core electric arc
      final arcPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFF2DD4BF)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, arcPaint);
    }

    // 4. Central tactile knob body (hard extruded disc)
    final knobRadius = trackRadius - 22;
    final knobRect = Rect.fromCircle(center: center, radius: knobRadius);

    final knobGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF222938), Color(0xFF151822)]
          : const [Color(0xFFF3F7FD), Color(0xFFE2E9F3)],
    );

    final knobPaint = Paint()
      ..shader = knobGrad.createShader(knobRect)
      ..style = PaintingStyle.fill;

    // Hard bevel border
    final knobBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF2E394E) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, knobRadius, knobPaint);
    canvas.drawCircle(center, knobRadius, knobBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _DeckRotaryPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.isDark != isDark;
  }
}
