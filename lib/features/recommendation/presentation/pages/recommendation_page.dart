import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.recommendationTitle)),
    );
  }
}
