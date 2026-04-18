import 'package:flutter/material.dart';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A1A2E),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1A1A2E),
    elevation: 0,
    centerTitle: false,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
);
