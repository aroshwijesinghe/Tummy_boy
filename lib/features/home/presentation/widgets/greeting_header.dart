import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

/// Top deck header with time-aware greeting and audio-deck pill style theme switch.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: textCol,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tummy Boy Deck Active',
                style: TextStyle(
                  color: subCol,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Audio-deck style theme toggle pill button (matching reference image top-right)
          ListenableBuilder(
            listenable: ThemeController.instance,
            builder: (context, _) {
              final isCurrentDark = ThemeController.instance.isDarkMode;
              return NeumorphicContainer(
                width: 52,
                height: 52,
                isCircle: true,
                glowColor: isCurrentDark ? AppColors.neonCyan : null,
                padding: EdgeInsets.zero,
                onTap: () => ThemeController.instance.toggleTheme(),
                child: Center(
                  child: Icon(
                    isCurrentDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isCurrentDark ? AppColors.neonCyan : const Color(0xFF0284C7),
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
