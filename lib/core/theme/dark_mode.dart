import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0F19),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF151D29),
    primary: Color(0xFF00E5FF),
    secondary: Color(0xFFB388FF),
    inversePrimary: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: const Color(0xFF00E5FF),
    unselectedLabelColor: Colors.white38,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: const Color(0x2600E5FF), // 15% opacity
      border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
    ),
  ),
  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    iconColor: const Color(0xFF00E5FF),
    textColor: Colors.white,
    selectedColor: const Color(0xFF00E5FF),
    selectedTileColor: const Color(0x1A00E5FF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF151D29),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E293B),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.white38),
  ),
);
