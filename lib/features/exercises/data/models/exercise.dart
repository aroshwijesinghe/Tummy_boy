import 'package:flutter/material.dart';

/// Represents a trackable exercise (built-in or custom).
class Exercise {
  final String id;
  final String name;
  final String unit; // "reps", "km", "seconds", "minutes"
  final IconData icon;
  final Color accentColor;
  final bool isBuiltIn;

  const Exercise({
    required this.id,
    required this.name,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.isBuiltIn = false,
  });

  bool get isCustom => !isBuiltIn;

  /// SharedPreferences key for a given date.
  String dailyKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'exercise_${id}_$y-$m-$d';
  }

  /// Serialize for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'iconCode': icon.codePoint,
        'colorValue': accentColor.toARGB32(),
        'isBuiltIn': isBuiltIn,
      };

  /// Deserialize from SharedPreferences.
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
        accentColor: Color(json['colorValue'] as int),
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      );
}
