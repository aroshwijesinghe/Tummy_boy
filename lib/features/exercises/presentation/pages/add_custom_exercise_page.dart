import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/exercise_defaults.dart';
import '../../../../shared/widgets/neumorphic_container.dart';
import '../../data/models/exercise.dart';
import '../../../../core/services/storage_service.dart';

class AddCustomExercisePage extends StatefulWidget {
  const AddCustomExercisePage({super.key});

  @override
  State<AddCustomExercisePage> createState() => _AddCustomExercisePageState();
}

class _AddCustomExercisePageState extends State<AddCustomExercisePage> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController(text: '20');

  final List<String> _units = ['reps', 'km', 'seconds', 'minutes', 'sets'];
  String _selectedUnit = 'reps';

  IconData _selectedIcon = ExerciseDefaults.availableIcons[0];
  Color _selectedColor = ExerciseDefaults.availableColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an exercise name')),
      );
      return;
    }

    final id = '${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

    final newExercise = Exercise(
      id: id,
      name: name,
      unit: _selectedUnit,
      icon: _selectedIcon,
      accentColor: _selectedColor,
      isBuiltIn: false,
    );

    await StorageService.addCustomExercise(newExercise);

    final goalText = _goalController.text.trim();
    final goalVal = double.tryParse(goalText);
    if (goalVal != null && goalVal > 0) {
      await StorageService.setGoal(newExercise, goalVal);
      // Automatically assign new customized exercise to Home screen deck
      await StorageService.toggleExerciseActive(newExercise.id, true);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight;
    final textCol = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subCol = isDark ? AppColors.textDim : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Custom Module',
          style: TextStyle(color: textCol, fontWeight: FontWeight.w800),
        ),
        iconTheme: IconThemeData(color: textCol),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MODULE IDENTIFIER',
              style: TextStyle(color: subCol, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            NeumorphicContainer(
              isInset: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameController,
                style: TextStyle(color: textCol, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g., Pull-ups, Burpees, Cycling',
                  hintStyle: TextStyle(color: subCol),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'MEASUREMENT UNIT',
              style: TextStyle(color: subCol, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _units.map((u) {
                final isSelected = _selectedUnit == u;
                return GestureDetector(
                  onTap: () => setState(() => _selectedUnit = u),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF222B3D) : const Color(0xFFE2EAF4))
                          : (isDark ? const Color(0xFF151822) : const Color(0xFFEDF2F9)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: isDark ? 0.3 : 0.2),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      u.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? AppColors.neonCyan : subCol,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            Text(
              'DAILY TARGET GOAL',
              style: TextStyle(color: subCol, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            NeumorphicContainer(
              isInset: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _goalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textCol, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g., 20',
                  hintStyle: TextStyle(color: subCol),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'ICON GLYPH',
              style: TextStyle(color: subCol, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: ExerciseDefaults.availableIcons.length,
              itemBuilder: (context, index) {
                final icon = ExerciseDefaults.availableIcons[index];
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (isDark ? const Color(0xFF222B3D) : const Color(0xFFE2EAF4))
                          : (isDark ? const Color(0xFF161923) : const Color(0xFFEDF2F9)),
                      border: Border.all(
                        color: isSelected ? AppColors.neonCyan : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: isDark ? 0.4 : 0.25),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.neonCyan : subCol,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            Text(
              'ACCENT COLOR',
              style: TextStyle(color: subCol, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ExerciseDefaults.availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                          blurRadius: isSelected ? 12 : 4,
                          spreadRadius: isSelected ? 2 : 0,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 44),

            // Save Module Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'SAVE MODULE',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: AppColors.neonCyan.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
