import 'package:flutter/material.dart';

/// A custom-crafted, hard-neumorphic geometric vector badge for every exercise.
/// Matches the tactile debossed/embossed hardware style with athletic wireframe glyphs.
class ExerciseBadgeIcon extends StatelessWidget {
  final String exerciseId;
  final IconData fallbackIcon;
  final Color accentColor;
  final double size;
  final bool isSelected;
  final bool showGlow;

  const ExerciseBadgeIcon({
    super.key,
    required this.exerciseId,
    required this.fallbackIcon,
    required this.accentColor,
    this.size = 46,
    this.isSelected = false,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? (isSelected
                  ? [const Color(0xFF283248), const Color(0xFF1B202D)]
                  : [const Color(0xFF1F2432), const Color(0xFF141722)])
              : (isSelected
                  ? [const Color(0xFFE0EAF6), const Color(0xFFCFDCED)]
                  : [const Color(0xFFF2F6FC), const Color(0xFFE1E8F2)]),
        ),
        border: Border.all(
          color: isSelected
              ? accentColor
              : accentColor.withValues(alpha: isDark ? 0.45 : 0.35),
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: isDark ? const Color(0xFF07090F) : const Color(0xFFA5B4C9),
                  offset: const Offset(3, 4),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: isDark ? const Color(0xFF2B3346) : const Color(0xFFFFFFFF),
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                ),
                if (isSelected)
                  BoxShadow(
                    color: accentColor.withValues(alpha: isDark ? 0.45 : 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.58, size * 0.58),
          painter: _ExerciseGlyphPainter(
            exerciseId: exerciseId,
            accentColor: accentColor,
            isDark: isDark,
          ),
          child: SizedBox(
            width: size * 0.58,
            height: size * 0.58,
            child: _hasCustomPainter(exerciseId)
                ? null
                : Icon(
                    fallbackIcon,
                    size: size * 0.52,
                    color: accentColor,
                  ),
          ),
        ),
      ),
    );
  }

  static bool _hasCustomPainter(String id) {
    final clean = id.toLowerCase();
    return clean.contains('pushup') ||
        clean.contains('squat') ||
        clean.contains('run') ||
        clean.contains('jump') ||
        clean.contains('plank') ||
        clean.contains('situp');
  }
}

class _ExerciseGlyphPainter extends CustomPainter {
  final String exerciseId;
  final Color accentColor;
  final bool isDark;

  _ExerciseGlyphPainter({
    required this.exerciseId,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final clean = exerciseId.toLowerCase();

    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    if (clean.contains('pushup')) {
      _drawPushup(canvas, w, h, strokePaint, fillPaint);
    } else if (clean.contains('squat')) {
      _drawSquat(canvas, w, h, strokePaint, fillPaint);
    } else if (clean.contains('run')) {
      _drawRunning(canvas, w, h, strokePaint, fillPaint);
    } else if (clean.contains('jump')) {
      _drawJumpingJacks(canvas, w, h, strokePaint, fillPaint);
    } else if (clean.contains('plank')) {
      _drawPlank(canvas, w, h, strokePaint, fillPaint);
    } else if (clean.contains('situp')) {
      _drawSitup(canvas, w, h, strokePaint, fillPaint);
    }
  }

  // 1. PUSHUP: Athlete horizontal plank with bent arms dipping down
  void _drawPushup(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Ground floor line
    canvas.drawLine(Offset(0, h * 0.88), Offset(w, h * 0.88), stroke..strokeWidth = 1.6);
    stroke.strokeWidth = 2.2;

    // Head
    canvas.drawCircle(Offset(w * 0.78, h * 0.38), w * 0.09, fill);

    // Torso line from head to hips
    final bodyPath = Path()
      ..moveTo(w * 0.72, h * 0.44)
      ..lineTo(w * 0.42, h * 0.52) // Torso / hips
      ..lineTo(w * 0.16, h * 0.78); // Straight legs to toes
    canvas.drawPath(bodyPath, stroke);

    // Arm (Shoulder down, forearm at 90 angle pressing floor)
    final armPath = Path()
      ..moveTo(w * 0.62, h * 0.46)
      ..lineTo(w * 0.68, h * 0.66) // Elbow
      ..lineTo(w * 0.64, h * 0.86); // Palm on ground
    canvas.drawPath(armPath, stroke);

    // Feet touch floor
    canvas.drawCircle(Offset(w * 0.16, h * 0.86), w * 0.04, fill);
  }

  // 2. SQUAT: Deep athletic squat posture
  void _drawSquat(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Head
    canvas.drawCircle(Offset(w * 0.48, h * 0.18), w * 0.09, fill);

    // Torso leaning forward slightly
    final spinePath = Path()
      ..moveTo(w * 0.48, h * 0.28)
      ..lineTo(w * 0.44, h * 0.52); // Hips low
    canvas.drawPath(spinePath, stroke);

    // Thigh parallel and calf to foot
    final legsPath = Path()
      ..moveTo(w * 0.44, h * 0.52)
      ..lineTo(w * 0.24, h * 0.55) // Thigh back
      ..lineTo(w * 0.28, h * 0.86) // Shin down
      ..lineTo(w * 0.38, h * 0.86); // Foot
    canvas.drawPath(legsPath, stroke);

    // Arms stretched straight forward for balance
    final armPath = Path()
      ..moveTo(w * 0.48, h * 0.34)
      ..lineTo(w * 0.78, h * 0.34);
    canvas.drawPath(armPath, stroke);

    // Ground platform line
    canvas.drawLine(Offset(w * 0.15, h * 0.90), Offset(w * 0.85, h * 0.90), stroke..strokeWidth = 1.4);
  }

  // 3. RUNNING: High-cadence dynamic sprinter
  void _drawRunning(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Head angled forward
    canvas.drawCircle(Offset(w * 0.62, h * 0.18), w * 0.09, fill);

    // Torso forward lean
    final torso = Path()
      ..moveTo(w * 0.60, h * 0.27)
      ..lineTo(w * 0.46, h * 0.52);
    canvas.drawPath(torso, stroke);

    // Front high knee leg
    final frontLeg = Path()
      ..moveTo(w * 0.46, h * 0.52)
      ..lineTo(w * 0.68, h * 0.58) // High knee
      ..lineTo(w * 0.62, h * 0.84); // Lower leg
    canvas.drawPath(frontLeg, stroke);

    // Back drive leg
    final backLeg = Path()
      ..moveTo(w * 0.46, h * 0.52)
      ..lineTo(w * 0.28, h * 0.66) // Thigh back
      ..lineTo(w * 0.16, h * 0.82); // Extended foot
    canvas.drawPath(backLeg, stroke);

    // Forward drive arm
    final frontArm = Path()
      ..moveTo(w * 0.56, h * 0.33)
      ..lineTo(w * 0.74, h * 0.44);
    canvas.drawPath(frontArm, stroke);

    // Rear pumping arm
    final backArm = Path()
      ..moveTo(w * 0.56, h * 0.33)
      ..lineTo(w * 0.36, h * 0.40)
      ..lineTo(w * 0.30, h * 0.26);
    canvas.drawPath(backArm, stroke);
  }

  // 4. JUMPING JACKS: Star posture with arms overhead and legs flared
  void _drawJumpingJacks(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Head at top
    canvas.drawCircle(Offset(w * 0.50, h * 0.17), w * 0.09, fill);

    // Torso
    canvas.drawLine(Offset(w * 0.50, h * 0.26), Offset(w * 0.50, h * 0.55), stroke);

    // Arms in 'V' angle high overhead
    final arms = Path()
      ..moveTo(w * 0.20, h * 0.18) // Left hand
      ..lineTo(w * 0.36, h * 0.28) // Left shoulder
      ..lineTo(w * 0.50, h * 0.32) // Chest
      ..lineTo(w * 0.64, h * 0.28) // Right shoulder
      ..lineTo(w * 0.80, h * 0.18); // Right hand
    canvas.drawPath(arms, stroke);

    // Legs spread wide in inverted 'V'
    final legs = Path()
      ..moveTo(w * 0.22, h * 0.88) // Left foot
      ..lineTo(w * 0.50, h * 0.55) // Pelvis
      ..lineTo(w * 0.78, h * 0.88); // Right foot
    canvas.drawPath(legs, stroke);
  }

  // 5. PLANK: Flat rigid isometric hold
  void _drawPlank(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Floor level
    canvas.drawLine(Offset(w * 0.08, h * 0.84), Offset(w * 0.92, h * 0.84), stroke..strokeWidth = 1.4);
    stroke.strokeWidth = 2.2;

    // Head
    canvas.drawCircle(Offset(w * 0.80, h * 0.44), w * 0.08, fill);

    // Perfectly flat isometric back & legs
    final spine = Path()
      ..moveTo(w * 0.74, h * 0.50)
      ..lineTo(w * 0.18, h * 0.70); // Perfectly straight plank line
    canvas.drawPath(spine, stroke);

    // Forearm vertical to floor
    final arm = Path()
      ..moveTo(w * 0.64, h * 0.53)
      ..lineTo(w * 0.64, h * 0.72) // Elbow
      ..lineTo(w * 0.74, h * 0.82); // Hand on floor
    canvas.drawPath(arm, stroke);

    // Feet toes on ground
    canvas.drawCircle(Offset(w * 0.18, h * 0.82), w * 0.04, fill);
  }

  // 6. SIT-UP: Abdominal crunch pose
  void _drawSitup(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Mat / Floor line
    canvas.drawLine(Offset(w * 0.08, h * 0.86), Offset(w * 0.92, h * 0.86), stroke..strokeWidth = 1.4);
    stroke.strokeWidth = 2.2;

    // Head elevated doing crunch
    canvas.drawCircle(Offset(w * 0.36, h * 0.34), w * 0.09, fill);

    // Curled torso (crunching up from hips)
    final torso = Path()
      ..moveTo(w * 0.38, h * 0.43)
      ..lineTo(w * 0.48, h * 0.70) // Hips on floor
      ..lineTo(w * 0.68, h * 0.56) // Bent knees up in triangle
      ..lineTo(w * 0.82, h * 0.84); // Flat feet on ground
    canvas.drawPath(torso, stroke);

    // Hands behind head
    final arms = Path()
      ..moveTo(w * 0.40, h * 0.45)
      ..lineTo(w * 0.28, h * 0.36);
    canvas.drawPath(arms, stroke);
  }

  @override
  bool shouldRepaint(covariant _ExerciseGlyphPainter oldDelegate) {
    return oldDelegate.exerciseId != exerciseId ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}
