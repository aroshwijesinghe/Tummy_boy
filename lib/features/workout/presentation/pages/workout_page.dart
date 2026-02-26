import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.workoutTitle)),
    );
  }
}
