import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Hard neumorphic theme supporting both Dark and Light mode.
class NeumorphicTheme {
  NeumorphicTheme._();

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDeepDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonCyan,
          secondary: AppColors.accentGlow,
          surface: AppColors.bgSurfaceDark,
          onPrimary: AppColors.bgDeepDark,
          onSecondary: AppColors.bgDeepDark,
          onSurface: AppColors.textPrimary,
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgCardDark,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderDark, width: 1.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgSurfaceDark,
          selectedItemColor: AppColors.neonCyan,
          unselectedItemColor: AppColors.textDim,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodySmall: TextStyle(color: AppColors.textDim),
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        dividerColor: AppColors.borderDark,
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDeepLight,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0284C7),
          secondary: Color(0xFF0EA5E9),
          surface: AppColors.bgSurfaceLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgCardLight,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderLight, width: 1.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgSurfaceLight,
          selectedItemColor: Color(0xFF0284C7),
          unselectedItemColor: Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
          bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF475569)),
        dividerColor: AppColors.borderLight,
      );
}
