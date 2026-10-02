import 'package:flutter/material.dart';

/// A hard neumorphic container matching the tactile audio-deck design style.
/// Supports both Dark and Light mode, raised extruded bevels, debossed inset sockets,
/// and neon glowing accents.
class NeumorphicContainer extends StatelessWidget {
  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.isInset = false,
    this.isCircle = false,
    this.glowColor,
    this.onTap,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isInset;
  final bool isCircle;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark mode hard neumorphic palette
    const darkFaceRaised = [Color(0xFF1F2533), Color(0xFF161922)];
    const darkFaceInset = [Color(0xFF0F121A), Color(0xFF141722)];
    const darkHighlight = Color(0xFF2C3549);
    const darkShadow = Color(0xFF06080E);
    final darkBorder = isInset ? const Color(0xFF1E2535) : const Color(0xFF283246);

    // Light mode hard neumorphic palette
    const lightFaceRaised = [Color(0xFFF0F5FD), Color(0xFFE2E9F3)];
    const lightFaceInset = [Color(0xFFD6DFEB), Color(0xFFE2EAF4)];
    const lightHighlight = Color(0xFFFFFFFF);
    const lightShadow = Color(0xFFA6B5CB);
    final lightBorder = isInset ? const Color(0xFFCBD6E4) : const Color(0xFFDFE6F1);

    final gradientColors = isDark
        ? (isInset ? darkFaceInset : darkFaceRaised)
        : (isInset ? lightFaceInset : lightFaceRaised);

    final highlightCol = isDark ? darkHighlight : lightHighlight;
    final shadowCol = isDark ? darkShadow : lightShadow;
    final borderCol = isDark ? darkBorder : lightBorder;

    final shape = isCircle ? BoxShape.circle : BoxShape.rectangle;
    final radius = isCircle ? null : BorderRadius.circular(borderRadius);

    List<BoxShadow> shadows;
    if (glowColor != null) {
      // Audio-deck glowing neon border
      shadows = [
        BoxShadow(
          color: glowColor!.withValues(alpha: 0.35),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: shadowCol,
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: highlightCol.withValues(alpha: 0.8),
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
      ];
    } else if (isInset) {
      // Inset debossed socket / well
      shadows = [
        BoxShadow(
          color: shadowCol.withValues(alpha: 0.8),
          offset: const Offset(3, 3),
          blurRadius: 4,
        ),
        BoxShadow(
          color: highlightCol.withValues(alpha: 0.4),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
      ];
    } else {
      // Tactile hard raised extruded button/card
      shadows = [
        BoxShadow(
          color: shadowCol,
          offset: const Offset(5, 5),
          blurRadius: 10,
        ),
        BoxShadow(
          color: highlightCol,
          offset: const Offset(-4, -4),
          blurRadius: 8,
        ),
      ];
    }

    final container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: glowColor != null ? glowColor!.withValues(alpha: 0.6) : borderCol,
          width: glowColor != null ? 1.5 : 1.0,
        ),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}
