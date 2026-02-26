import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class RunPage extends StatelessWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.runTitle)),
    );
  }
}
