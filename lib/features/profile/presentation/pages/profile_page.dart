import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/neumorphic_container.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onChangePinPressed});

  final VoidCallback? onChangePinPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Control Deck',
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Center avatar deck knob
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF232A3B), Color(0xFF151923)]
                      : const [Color(0xFFF3F7FD), Color(0xFFE2E9F3)],
                ),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 48, color: AppColors.neonCyan),
            ),
            const SizedBox(height: 14),
            Text(
              'Champion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textCol,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hardware-calibrated Fitness Tracker',
              style: TextStyle(fontSize: 13, color: subCol),
            ),
            const SizedBox(height: 32),

            // Theme Switch Item (Dark / Light mode)
            ListenableBuilder(
              listenable: ThemeController.instance,
              builder: (context, _) {
                final isCurrentDark = ThemeController.instance.isDarkMode;
                return NeumorphicContainer(
                  onTap: () => ThemeController.instance.toggleTheme(),
                  child: Row(
                    children: [
                      Icon(
                        isCurrentDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        color: isCurrentDark ? AppColors.neonCyan : const Color(0xFFF59E0B),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme Mode',
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCurrentDark ? 'Dark Deck Mode' : 'Light Slate Mode',
                              style: TextStyle(color: subCol, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isCurrentDark,
                        activeThumbColor: AppColors.neonCyan,
                        onChanged: (_) => ThemeController.instance.toggleTheme(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Settings items
            _buildSettingItem(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Change PIN',
              subtitle: 'Update your 4-digit security PIN',
              onTap: onChangePinPressed,
            ),
            const SizedBox(height: 14),
            _buildSettingItem(
              context,
              icon: Icons.delete_outline_rounded,
              title: 'Reset All Data',
              subtitle: 'Clear all workout history and custom exercises',
              onTap: () => _showResetDialog(context),
              isDestructive: true,
            ),
            const SizedBox(height: 14),
            _buildSettingItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'Deck Calibration',
              subtitle: 'Tummy Boy v0.1.0 • Hard Neumorphic Engine',
              onTap: null,
            ),
            const SizedBox(height: 28),

            // CONTACT DETAILS SECTION (Website & Email only)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CONTACT',
                style: TextStyle(
                  color: subCol,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            NeumorphicContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Website / Portfolio Item
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Website: https://portfoilo-ruddy-two.vercel.app/'),
                          backgroundColor: AppColors.neonCyan,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonCyan.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.2),
                          ),
                          child: const Icon(Icons.language_rounded, color: AppColors.neonCyan, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portfolio Website',
                                style: TextStyle(color: subCol, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'https://portfoilo-ruddy-two.vercel.app/',
                                style: TextStyle(
                                  color: textCol,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.open_in_new_rounded, color: subCol, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
                  const SizedBox(height: 14),
                  // Email Item
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email: aroshwijesingha@gmail.com'),
                          backgroundColor: AppColors.neonCyan,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonCyan.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.2),
                          ),
                          child: const Icon(Icons.email_outlined, color: AppColors.neonCyan, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(color: subCol, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'aroshwijesingha@gmail.com',
                                style: TextStyle(
                                  color: textCol,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.copy_rounded, color: subCol, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);
    final color = isDestructive ? AppColors.situpColor : (isDark ? AppColors.neonCyan : const Color(0xFF0284C7));

    return NeumorphicContainer(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? color : textCol,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: subCol, fontSize: 12)),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: subCol, size: 22),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.bgCardDark : AppColors.bgCardLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset All Data?', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete all exercise history, custom exercises, and settings. This cannot be undone.',
          style: TextStyle(color: isDark ? AppColors.textSecondary : const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textDim : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.situpColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await StorageService.clearAllData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset'),
                    backgroundColor: AppColors.situpColor,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
