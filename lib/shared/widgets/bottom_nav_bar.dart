import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/glow_icon.dart';

/// Custom hard neumorphic bottom navigation bar matching the audio-deck aesthetic.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.speed_rounded, label: 'Deck'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Workouts'),
    _NavItem(icon: Icons.equalizer_rounded, label: 'Metrics'),
    _NavItem(icon: Icons.tune_rounded, label: 'Control'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF13161F) : const Color(0xFFE2E8F0);
    final borderCol = isDark ? const Color(0xFF242C3D) : const Color(0xFFCAD5E2);
    final shadowCol = isDark ? const Color(0xFF07090F) : const Color(0xFFA5B2C6);
    const activeCol = AppColors.neonCyan;
    final inactiveCol = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: bgCol,
        border: Border(top: BorderSide(color: borderCol, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: shadowCol.withValues(alpha: isDark ? 0.6 : 0.3),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isActive
                      ? (isDark ? const Color(0xFF191D28) : const Color(0xFFEDF2F9))
                      : Colors.transparent,
                  border: isActive
                      ? Border.all(
                          color: activeCol.withValues(alpha: isDark ? 0.5 : 0.4),
                          width: 1.0,
                        )
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeCol.withValues(alpha: isDark ? 0.25 : 0.15),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: shadowCol.withValues(alpha: 0.4),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      GlowIcon(
                        icon: item.icon,
                        size: 24,
                        color: activeCol,
                        glowRadius: 8,
                      )
                    else
                      Icon(item.icon, size: 22, color: inactiveCol),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? activeCol : inactiveCol,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
