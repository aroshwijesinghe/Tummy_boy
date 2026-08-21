// lib/theme/dark_theme.dart
import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  canvasColor: const Color(0xFF121212),
  dividerColor: Colors.grey[700],
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: Colors.white70),
    bodyText2: TextStyle(color: Colors.white70),
    headline6: TextStyle(color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
);
