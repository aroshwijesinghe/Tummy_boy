import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/recommendation/presentation/pages/recommendation_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/run/presentation/pages/run_page.dart';
import '../features/workout/presentation/pages/workout_page.dart';

class AppRouter {
  static const home = '/';
  static const workout = '/workout';
  static const run = '/run';
  static const reports = '/reports';
  static const profile = '/profile';
  static const recommendation = '/recommendation';

  static final routes = <String, WidgetBuilder>{
    home: (_) => const HomePage(),
    workout: (_) => const WorkoutPage(),
    run: (_) => const RunPage(),
    reports: (_) => const ReportsPage(),
    profile: (_) => const ProfilePage(),
    recommendation: (_) => const RecommendationPage(),
  };
}
