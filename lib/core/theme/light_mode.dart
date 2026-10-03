import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF38BDF8),
    inversePrimary: Color(0xFF0F172A),
    onSurface: Color(0xFF0F172A),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    titleTextStyle: TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: const Color(0xFF6366F1),
    unselectedLabelColor: Colors.black38,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: const Color(0x1A6366F1),
      border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
    ),
  ),
  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    iconColor: const Color(0xFF6366F1),
    textColor: const Color(0xFF0F172A),
    selectedColor: const Color(0xFF6366F1),
    selectedTileColor: const Color(0x0D6366F1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.black38),
  ),
);
