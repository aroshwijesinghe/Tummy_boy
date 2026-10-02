import 'package:flutter/foundation.dart';

/// Global notifier for workout, goal, and exercise state mutations.
/// Whenever exercises are created, deleted, toggled, or logged, notifying this
/// triggers immediate instant refresh across HomePage, ExerciseListPage, and StatisticsPage.
class AppDataSync extends ChangeNotifier {
  AppDataSync._();
  static final AppDataSync instance = AppDataSync._();

  int _version = 0;
  int get version => _version;

  void notifyDataChanged() {
    _version++;
    notifyListeners();
  }
}
