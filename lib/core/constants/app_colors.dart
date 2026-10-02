import 'package:flutter/material.dart';

/// Central color palette for the hard neumorphic UI supporting Dark and Light modes.
class AppColors {
  AppColors._();

  // ── Dark Mode Hard Neumorphic Colors ──
  static const Color bgDeepDark = Color(0xFF12151E);
  static const Color bgSurfaceDark = Color(0xFF181C28);
  static const Color bgCardDark = Color(0xFF1A1F2C);
  static const Color bgInputDark = Color(0xFF0F121A);

  static const Color shadowDarkBlack = Color(0xFF07090F);
  static const Color shadowDarkHighlight = Color(0xFF283042);
  static const Color borderDark = Color(0xFF242C3D);

  // ── Light Mode Hard Neumorphic Colors ──
  static const Color bgDeepLight = Color(0xFFE2E8F0);
  static const Color bgSurfaceLight = Color(0xFFEBF1F8);
  static const Color bgCardLight = Color(0xFFEDF2F9);
  static const Color bgInputLight = Color(0xFFD3DBE7);

  static const Color shadowLightDark = Color(0xFFA5B2C6);
  static const Color shadowLightHighlight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFCBD5E1);

  // ── Electric Neon Accents (Audio Deck Style) ──
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGlow = Color(0xFF38BDF8);
  static const Color accentDim = Color(0xFF0284C7);

  // ── Exercise-specific accents ──
  static const Color pushupColor = Color(0xFF00E5FF);
  static const Color squatColor = Color(0xFFA78BFA);
  static const Color runColor = Color(0xFF38BDF8);
  static const Color jumpColor = Color(0xFFFBBF24);
  static const Color plankColor = Color(0xFF34D399);
  static const Color situpColor = Color(0xFFF87171);

  // ── Stamina ring gradients ──
  static const Color staminaHigh = Color(0xFF00E5FF);
  static const Color staminaMid = Color(0xFFFBBF24);
  static const Color staminaLow = Color(0xFFEF4444);

  // ── Default / Dark Fallbacks for direct access ──
  static const Color bgDeep = bgDeepDark;
  static const Color bgSurface = bgSurfaceDark;
  static const Color bgCard = bgCardDark;
  static const Color bgInput = bgInputDark;
  static const Color shadowDark = shadowDarkBlack;
  static const Color shadowLight = shadowDarkHighlight;
  static const Color border = borderDark;
  static const Color borderActive = neonCyan;

  // ── Text ──
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);

  // ── Context-aware adaptive getters ──
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? bgDeepDark : bgDeepLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? bgSurfaceDark : bgSurfaceLight;

  static Color card(BuildContext context) =>
      isDark(context) ? bgCardDark : bgCardLight;

  static Color socket(BuildContext context) =>
      isDark(context) ? bgInputDark : bgInputLight;

  static Color borderCol(BuildContext context) =>
      isDark(context) ? borderDark : borderLight;

  static Color text(BuildContext context) =>
      isDark(context) ? textPrimary : const Color(0xFF0F172A);

  static Color textSub(BuildContext context) =>
      isDark(context) ? textSecondary : const Color(0xFF475569);

  static Color textMuted(BuildContext context) =>
      isDark(context) ? textDim : const Color(0xFF94A3B8);
}
