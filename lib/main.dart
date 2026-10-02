import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.init();

  // Lock to portrait for optimal neumorphic layout
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark status bar to match the neumorphic theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF111827),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const TummyBoyApp());
}
