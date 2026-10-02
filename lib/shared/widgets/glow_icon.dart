import 'package:flutter/material.dart';

/// An icon wrapped in a soft glowing neon aura.
class GlowIcon extends StatelessWidget {
  const GlowIcon({
    super.key,
    required this.icon,
    this.size = 28,
    this.color = const Color(0xFF00E5FF),
    this.glowRadius = 12,
  });

  final IconData icon;
  final double size;
  final Color color;
  final double glowRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}
