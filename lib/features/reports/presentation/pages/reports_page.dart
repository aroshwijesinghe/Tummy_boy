import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.reportsTitle)),
    );
  }
}
