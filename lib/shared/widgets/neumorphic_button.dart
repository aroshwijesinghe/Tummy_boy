import 'package:flutter/material.dart';

/// A hard neumorphic button with tactile extruded resting state and debossed pressed state,
/// mirroring the physical deck buttons in the reference image.
class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 64,
    this.isCircular = true,
    this.glowColor,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double size;
  final bool isCircular;
  final Color? glowColor;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const darkFaceRaised = [Color(0xFF222938), Color(0xFF161923)];
    const darkFacePressed = [Color(0xFF0F121A), Color(0xFF141822)];
    const darkHighlight = Color(0xFF2E384D);
    const darkShadow = Color(0xFF06080E);
    const darkBorder = Color(0xFF283246);

    const lightFaceRaised = [Color(0xFFF3F7FD), Color(0xFFE2E9F3)];
    const lightFacePressed = [Color(0xFFD6DFEB), Color(0xFFE0E8F2)];
    const lightHighlight = Color(0xFFFFFFFF);
    const lightShadow = Color(0xFFA6B5CB);
    const lightBorder = Color(0xFFDFE6F1);

    final gradientColors = isDark
        ? (_isPressed ? darkFacePressed : darkFaceRaised)
        : (_isPressed ? lightFacePressed : lightFaceRaised);

    final highlightCol = isDark ? darkHighlight : lightHighlight;
    final shadowCol = isDark ? darkShadow : lightShadow;
    final borderCol = isDark ? darkBorder : lightBorder;

    List<BoxShadow> shadows;
    if (_isPressed) {
      shadows = [
        BoxShadow(
          color: shadowCol.withValues(alpha: 0.9),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: highlightCol.withValues(alpha: 0.3),
          offset: const Offset(-1, -1),
          blurRadius: 2,
        ),
      ];
    } else if (widget.glowColor != null) {
      shadows = [
        BoxShadow(
          color: widget.glowColor!.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: shadowCol,
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: highlightCol,
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
      ];
    } else {
      shadows = [
        BoxShadow(
          color: shadowCol,
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: highlightCol,
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
      ];
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color: widget.glowColor != null
                ? widget.glowColor!.withValues(alpha: 0.7)
                : borderCol,
            width: widget.glowColor != null ? 1.5 : 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
