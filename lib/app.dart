import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/neumorphic_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/exercises/presentation/pages/exercise_list_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/pin/data/pin_service.dart';
import 'features/pin/presentation/pages/pin_setup_page.dart';
import 'features/pin/presentation/pages/pin_verify_page.dart';
import 'core/services/app_data_sync.dart';
import 'shared/widgets/bottom_nav_bar.dart';

class TummyBoyApp extends StatelessWidget {
  const TummyBoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Tummy Boy Fitness',
          debugShowCheckedModeBanner: false,
          theme: NeumorphicTheme.lightTheme,
          darkTheme: NeumorphicTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          home: const AppGate(),
        );
      },
    );
  }
}

/// Gate: checks PIN status and routes to setup/verify/main accordingly.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _loading = true;
  bool _pinIsSet = false;
  bool _unlocked = false;
  bool _isResettingPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final isSet = await PinService.isPinSet();
    if (!mounted) return;
    setState(() {
      _pinIsSet = isSet;
      _loading = false;
    });
  }

  void _onPinSet() {
    setState(() {
      _pinIsSet = true;
      _unlocked = true;
      _isResettingPin = false;
    });
  }

  void _onVerified() {
    setState(() {
      _unlocked = true;
    });
  }

  void _startChangePin() {
    setState(() {
      _isResettingPin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    if (_isResettingPin || !_pinIsSet) {
      return PinSetupPage(onPinSet: _onPinSet);
    }

    if (!_unlocked) {
      return PinVerifyPage(onVerified: _onVerified);
    }

    return MainShell(onChangePin: _startChangePin);
  }
}

/// Main app shell with bottom navigation.
class MainShell extends StatefulWidget {
  final VoidCallback onChangePin;

  const MainShell({super.key, required this.onChangePin});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = <Widget>[
      const HomePage(),
      const ExerciseListPage(),
      const StatisticsPage(),
      ProfilePage(onChangePinPressed: widget.onChangePin),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeepDark : AppColors.bgDeepLight,
      body: IndexedStack(
        index: _currentTab,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
          // Instantly sync fresh exercises, goals, and stats when switching tabs
          AppDataSync.instance.notifyDataChanged();
        },
      ),
    );
  }
}
